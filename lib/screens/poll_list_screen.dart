import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/poll_providers.dart';
import 'create_poll_screen.dart';

class PollListScreen extends ConsumerWidget {
  const PollListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollsAsync = ref.watch(activePollsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RT Poll'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: pollsAsync.when(
        data: (polls) {
          if (polls.isEmpty) {
            return const Center(child: Text('No polls yet. Create one!'));
          }
          return ListView.builder(
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              return ListTile(
                title: Text(poll.title),
                subtitle: Text('${poll.totalVotes} votes'),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePollScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
