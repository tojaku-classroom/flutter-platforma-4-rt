import 'package:equatable/equatable.dart';

class PollOption extends Equatable {
  final String id;
  final String pollId;
  final String text;
  final int voteCount;

  const PollOption({
    required this.id,
    required this.pollId,
    required this.text,
    this.voteCount = 0,
  });

  factory PollOption.fromJson(
    Map<String, dynamic> json,
    String id,
    String pollId,
  ) {
    return PollOption(
      id: id,
      pollId: pollId,
      text: json['text'] as String,
      voteCount: json['voteCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'voteCount': voteCount};
  }

  PollOption copyWith({
    String? id,
    String? pollId,
    String? text,
    int? voteCount,
  }) {
    return PollOption(
      id: id ?? this.id,
      pollId: pollId ?? this.pollId,
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
    );
  }

  @override
  List<Object?> get props => [id, pollId, text, voteCount];
}
