import 'package:rtpoll/domain/models/vote.dart';
import 'package:rtpoll/domain/repositories/vote_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'firestore_poll_repository.dart';

class FirestoreVoteRepository implements VoteRepository {
  final FirebaseFirestore _firestore;
  final FirestorePollRepository _pollRepository;
  final Uuid _uuid;

  CollectionReference get _votesCollection => _firestore.collection('votes');

  FirestoreVoteRepository({
    FirebaseFirestore? firestore,
    required FirestorePollRepository pollRepository,
    Uuid? uuid,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _pollRepository = pollRepository,
       _uuid = uuid ?? const Uuid();

  @override
  Future<void> castVote({
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    final existingVote = await getUserVote(pollId, userId);
    if (existingVote != null) {
      throw Exception('User has already voted on this poll');
    }

    final voteId = _uuid.v4();
    final vote = Vote(
      id: voteId,
      pollId: pollId,
      optionId: optionId,
      userId: userId,
      votedAt: DateTime.now(),
    );

    await _votesCollection.doc(voteId).set(vote.toJson());
    await _pollRepository.incrementOptionVoteCount(pollId, optionId);
  }

  @override
  Future<void> changeVote({
    required String pollId,
    required String newOptionId,
    required String userId,
  }) async {
    final existingVote = await getUserVote(pollId, userId);
    if (existingVote == null) {
      throw Exception('No existing vote found for this user');
    }

    final oldOptionId = existingVote.optionId;
    if (oldOptionId == newOptionId) return;

    await _votesCollection.doc(existingVote.id).update({
      'optionId': newOptionId,
      'votedAt': DateTime.now().toIso8601String(),
    });

    await _pollRepository.decrementOptionVoteCount(pollId, oldOptionId);
    await _pollRepository.incrementOptionVoteCount(pollId, newOptionId);
  }

  @override
  Future<Vote?> getUserVote(String pollId, String userId) async {
    final querySnapshot = await _votesCollection
        .where('pollId', isEqualTo: pollId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    return Vote.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Future<void> removeVote({
    required String voteId,
    required String pollId,
    required String optionId,
  }) async {
    await _votesCollection.doc(voteId).delete();
    await _pollRepository.decrementOptionVoteCount(pollId, optionId);
  }

  @override
  Stream<List<Vote>> watchPollVotes(String pollId) {
    return _votesCollection
        .where('pollId', isEqualTo: pollId)
        .orderBy('votedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Vote.fromJson(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }
}
