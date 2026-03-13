import '../models/vote.dart';

abstract class VoteRepository {
  Stream<List<Vote>> watchPollVotes(String pollId);

  Future<Vote?> getUserVote(String pollId, String userId);
  Future<void> castVote({
    required String pollId,
    required String optionId,
    required String userId,
  });
  Future<void> changeVote({
    required String pollId,
    required String newOptionId,
    required String userId,
  });
  Future<void> removeVote({
    required String voteId,
    required String pollId,
    required String optionId,
  });
}
