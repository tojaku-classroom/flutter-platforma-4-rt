import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rtpoll/domain/models/poll.dart';
import 'package:rtpoll/domain/models/poll_option.dart';
import 'package:rtpoll/domain/repositories/poll_repository.dart';
import 'package:uuid/uuid.dart';

class FirestorePollRepository implements PollRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  FirestorePollRepository({FirebaseFirestore? firestore, Uuid? uuid})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _uuid = uuid ?? const Uuid();

  // Collection references
  CollectionReference get _pollsCollection => _firestore.collection('polls');
  CollectionReference _optionsCollection(String pollId) =>
      _pollsCollection.doc(pollId).collection('options');

  @override
  Future<String> createPoll({
    required String title,
    required String creatorId,
    required List<String> optionTexts,
  }) async {
    if (optionTexts.length < 2) {
      throw ArgumentError('A poll must have at least 2 options');
    }

    final pollId = _uuid.v4();
    final poll = Poll(
      id: pollId,
      title: title,
      creatorId: creatorId,
      createdAt: DateTime.now(),
      isActive: true,
      totalVotes: 0,
    );

    // Start batch write
    final batch = _firestore.batch();

    // Create poll document
    batch.set(_pollsCollection.doc(pollId), poll.toJson());

    // Create option subcollection documents
    for (final optionText in optionTexts) {
      final optionId = _uuid.v4();
      final option = PollOption(
        id: optionId,
        pollId: pollId,
        text: optionText,
        voteCount: 0,
      );

      // Add each option document to batch
      batch.set(_optionsCollection(pollId).doc(optionId), option.toJson());
    }

    // Write changes using batch (atomic)
    await batch.commit();
    return pollId;
  }

  @override
  Future<void> deletePoll(String pollId) async {
    await _pollsCollection.doc(pollId).delete();
  }

  @override
  Future<Poll?> getPoll(String pollId) async {
    final doc = await _pollsCollection.doc(pollId).get();
    if (!doc.exists) return null;
    return Poll.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Future<void> togglePollActive(String pollId, bool isActive) async {
    await _pollsCollection.doc(pollId).update({'isActive': isActive});
  }

  @override
  Stream<List<Poll>> watchActivePolls() {
    return _pollsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Poll.fromJson(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  @override
  Stream<Poll?> watchPoll(String pollId) {
    return _pollsCollection.doc(pollId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return Poll.fromJson(
        snapshot.data() as Map<String, dynamic>,
        snapshot.id,
      );
    });
  }

  @override
  Stream<List<PollOption>> watchPollOptions(String pollId) {
    return _optionsCollection(pollId).orderBy('text').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return PollOption.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
          pollId,
        );
      }).toList();
    });
  }

  Future<void> incrementOptionVoteCount(String pollId, String optionId) async {
    await _firestore.runTransaction((transaction) async {
      final optionRef = _optionsCollection(pollId).doc(optionId);
      final pollRef = _pollsCollection.doc(pollId);

      final optionSnapshot = await transaction.get(optionRef);
      final pollSnapshot = await transaction.get(pollRef);

      if (!optionSnapshot.exists || !pollSnapshot.exists) {
        throw Exception('Poll or option not found');
      }

      final currentVoteCount =
          (optionSnapshot.data() as Map<String, dynamic>)['voteCount']
              as int? ??
          0;
      final currentTotalVotes =
          (pollSnapshot.data() as Map<String, dynamic>)['totalVotes'] as int? ??
          0;

      transaction.update(optionRef, {'voteCount': currentVoteCount + 1});
      transaction.update(pollRef, {'totalVotes': currentTotalVotes + 1});
    });
  }

  Future<void> decrementOptionVoteCount(String pollId, String optionId) async {
    await _firestore.runTransaction((transaction) async {
      final optionRef = _optionsCollection(pollId).doc(optionId);
      final pollRef = _pollsCollection.doc(pollId);

      final optionSnapshot = await transaction.get(optionRef);
      final pollSnapshot = await transaction.get(pollRef);

      if (!optionSnapshot.exists || !pollSnapshot.exists) {
        throw Exception('Poll or option not found');
      }

      final currentVoteCount =
          (optionSnapshot.data() as Map<String, dynamic>)['voteCount']
              as int? ??
          0;
      final currentTotalVotes =
          (pollSnapshot.data() as Map<String, dynamic>)['totalVotes'] as int? ??
          0;

      transaction.update(optionRef, {
        'voteCount': (currentVoteCount - 1).clamp(0, double.infinity).toInt(),
      });
      transaction.update(pollRef, {
        'totalVotes': (currentTotalVotes - 1).clamp(0, double.infinity).toInt(),
      });
    });
  }
}
