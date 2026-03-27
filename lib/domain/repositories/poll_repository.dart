import '../models/poll.dart';
import '../models/poll_option.dart';

abstract class PollRepository {
  Stream<List<Poll>> watchActivePolls();
  Stream<Poll?> watchPoll(String pollId);
  Stream<List<PollOption>> watchPollOptions(String pollId);

  Future<String> createPoll({
    required String title,
    required String creatorId,
    required List<String> optionTexts,
  });
  Future<Poll?> getPoll(String pollId);
  Future<void> deletePoll(String pollId);
  Future<void> togglePollActive(String pollId, bool isActive);
}
