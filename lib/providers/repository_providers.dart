import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtpoll/data/repositories/firestore_poll_repository.dart';
import 'package:rtpoll/data/repositories/firestore_vote_repository.dart';
import 'package:rtpoll/domain/repositories/poll_repository.dart';
import 'package:rtpoll/domain/repositories/vote_repository.dart';
import 'package:uuid/uuid.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final uuidProvider = Provider<Uuid>((ref) {
  return const Uuid();
});

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  return FirestorePollRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
    uuid: ref.watch(uuidProvider),
  );
});

final voteRepositoryProvider = Provider<VoteRepository>((ref) {
  final pollRepository =
      ref.watch(pollRepositoryProvider) as FirestorePollRepository;

  return FirestoreVoteRepository(
    pollRepository: pollRepository,
    firestore: ref.watch(firebaseFirestoreProvider),
    uuid: ref.watch(uuidProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.uid,
    error: (error, stackTrace) => null,
    loading: () => null,
  );
});
