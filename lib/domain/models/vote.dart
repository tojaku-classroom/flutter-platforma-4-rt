import 'package:equatable/equatable.dart';

class Vote extends Equatable {
  final String id;
  final String pollId;
  final String optionId;
  final String userId;
  final DateTime votedAt;

  const Vote({
    required this.id,
    required this.pollId,
    required this.optionId,
    required this.userId,
    required this.votedAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json, String id) {
    return Vote(
      id: id,
      pollId: json['pollId'] as String,
      optionId: json['optionId'] as String,
      userId: json['userId'] as String,
      votedAt: DateTime.parse(json['votedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pollId': pollId,
      'optionId': optionId,
      'userId': userId,
      'votedAt': votedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, pollId, optionId, userId, votedAt];
}
