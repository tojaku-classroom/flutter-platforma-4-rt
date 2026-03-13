import 'package:equatable/equatable.dart';

class Poll extends Equatable {
  final String id;
  final String title;
  final String creatorId;
  final DateTime createdAt;
  final bool isActive;
  final int totalVotes;

  const Poll({
    required this.id,
    required this.title,
    required this.creatorId,
    required this.createdAt,
    this.isActive = true,
    this.totalVotes = 0,
  });

  factory Poll.fromJson(Map<String, dynamic> json, String id) {
    return Poll(
      id: id,
      title: json['title'] as String,
      creatorId: json['creatorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      totalVotes: json['totalVotes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'totalVotes': totalVotes,
    };
  }

  Poll copyWith({
    String? id,
    String? title,
    String? creatorId,
    DateTime? createdAt,
    bool? isActive,
    int? totalVotes,
  }) {
    return Poll(
      id: id ?? this.id,
      title: title ?? this.title,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      totalVotes: totalVotes ?? this.totalVotes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    creatorId,
    createdAt,
    isActive,
    totalVotes,
  ];
}
