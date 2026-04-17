import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/poll.dart';
import '../domain/models/poll_option.dart';
import '../domain/models/vote.dart';
import 'repository_providers.dart';

final activePollsProvider = StreamProvider<List<Poll>>((ref) {
  final repository = ref.watch(pollRepositoryProvider);
  return repository.watchActivePolls();
});

final pollProvider = StreamProvider.family<Poll?, String>((ref, pollId) {
  final repository = ref.watch(pollRepositoryProvider);
  return repository.watchPoll(pollId);
});

final pollOptionsProvider = StreamProvider.family<List<PollOption>, String>((
  ref,
  pollId,
) {
  final repository = ref.watch(pollRepositoryProvider);
  return repository.watchPollOptions(pollId);
});

final pollVotesProvider = StreamProvider.family<List<Vote>, String>((
  ref,
  pollId,
) {
  final repository = ref.watch(voteRepositoryProvider);
  return repository.watchPollVotes(pollId);
});

final userVoteProvider = FutureProvider.family<Vote?, String>((ref, pollId) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final repository = ref.watch(voteRepositoryProvider);
  return repository.getUserVote(pollId, userId);
});
