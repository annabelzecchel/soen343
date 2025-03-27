import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/poll_model.dart';
import '../controllers/poll_controller.dart';

class PollCreationWidget extends StatefulWidget {
  final String eventId;

  const PollCreationWidget({Key? key, required this.eventId}) : super(key: key);

  @override
  _PollCreationWidgetState createState() => _PollCreationWidgetState();
}

class _PollCreationWidgetState extends State<PollCreationWidget> {
  final _pollController = PollController();
  final _questionController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _createPoll() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('You must be logged in to create a poll');
      }

      await _pollController.createPoll(
        widget.eventId,
        user.email!,
        _questionController.text.trim(),
      );

      _questionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poll created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating poll: $e')),
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create a Poll',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                hintText: 'Ask a yes/no question...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isCreating ? null : _createPoll,
              child: _isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post Poll'),
            ),
          ],
        ),
      ),
    );
  }
}

class PollListWidget extends StatelessWidget {
  final String eventId;

  const PollListWidget({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _pollController = PollController();

    return StreamBuilder<List<Poll>>(
      stream: _pollController.getEventPolls(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final polls = snapshot.data ?? [];
        if (polls.isEmpty) {
          return const Center(child: Text('No polls yet. Create one!'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: polls.length,
          itemBuilder: (context, index) {
            final poll = polls[index];
            return PollWidget(poll: poll);
          },
        );
      },
    );
  }
}

class PollWidget extends StatelessWidget {
  final Poll poll;

  const PollWidget({Key? key, required this.poll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _pollController = PollController();
    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email;
    final userVote = userEmail != null ? poll.getUserVote(userEmail) : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poll.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Posted by: ${poll.createdByEmail}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildVoteButton(
                  context,
                  'up',
                  Icons.thumb_up,
                  Colors.green,
                  userVote == 'up',
                  () async {
                    if (userEmail != null) {
                      try {
                        await _pollController.submitVote(
                            poll.id, userEmail, 'up');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error voting: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('You must be logged in to vote')),
                      );
                    }
                  },
                ),
                _buildVoteButton(
                  context,
                  'down',
                  Icons.thumb_down,
                  Colors.red,
                  userVote == 'down',
                  () async {
                    if (userEmail != null) {
                      try {
                        await _pollController.submitVote(
                            poll.id, userEmail, 'down');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error voting: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('You must be logged in to vote')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildResultsBar(context, poll),
            const SizedBox(height: 8),
            Text(
              'Total votes: ${poll.totalVotes}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (userEmail != null && userEmail == poll.createdByEmail)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.all(4),
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Poll'),
                        content: const Text(
                            'Are you sure you want to delete this poll?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      try {
                        await _pollController.deletePoll(poll.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Poll deleted')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error deleting poll: $e')),
                        );
                      }
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteButton(
    BuildContext context,
    String voteType,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          icon: Icon(icon, color: isSelected ? Colors.white : color),
          label: Text(
            voteType == 'up'
                ? 'Yes (${poll.thumbsUpCount})'
                : 'No (${poll.thumbsDownCount})',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? color : Colors.white,
            foregroundColor: Colors.black,
            side: BorderSide(color: color),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildResultsBar(BuildContext context, Poll poll) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: poll.thumbsUpPercentage.round(),
            child: Container(
              color: poll.thumbsUpPercentage > 0
                  ? Colors.green[300]
                  : Colors.transparent,
              alignment: Alignment.center,
              child: poll.thumbsUpPercentage >= 20
                  ? Text(
                      '${poll.thumbsUpPercentage.round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
          ),
          Expanded(
            flex: poll.thumbsDownPercentage.round(),
            child: Container(
              color: poll.thumbsDownPercentage > 0
                  ? Colors.red[300]
                  : Colors.transparent,
              alignment: Alignment.center,
              child: poll.thumbsDownPercentage >= 20
                  ? Text(
                      '${poll.thumbsDownPercentage.round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
