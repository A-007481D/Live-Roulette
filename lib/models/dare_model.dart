enum DareType { solo, oneVsOne, group }
enum DareStatus { pending, live, completed, failed }
enum DareDifficulty { easy, medium, hard, extreme, insane }

class Dare {
  final String id;
  final String title;
  final String description;
  final DareType type;
  final DareDifficulty difficulty;
  final double submissionFee;
  final double currentTips;
  final int votes;
  final String submitterId;
  final String? performerId;
  final DareStatus status;
  final DateTime createdAt;
  final List<String> tags;
  final bool isSponsored;
  final String? sponsorBrand;

  Dare({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.submissionFee,
    this.currentTips = 0.0,
    this.votes = 0,
    required this.submitterId,
    this.performerId,
    this.status = DareStatus.pending,
    required this.createdAt,
    this.tags = const [],
    this.isSponsored = false,
    this.sponsorBrand,
  });

  factory Dare.fromMap(Map<String, dynamic> map) {
    return Dare(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: DareType.values[map['type'] ?? 0],
      difficulty: DareDifficulty.values[map['difficulty'] ?? 0],
      submissionFee: (map['submissionFee'] ?? 0.0).toDouble(),
      currentTips: (map['currentTips'] ?? 0.0).toDouble(),
      votes: map['votes'] ?? 0,
      submitterId: map['submitterId'] ?? '',
      performerId: map['performerId'],
      status: DareStatus.values[map['status'] ?? 0],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      tags: List<String>.from(map['tags'] ?? []),
      isSponsored: map['isSponsored'] ?? false,
      sponsorBrand: map['sponsorBrand'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'difficulty': difficulty.index,
      'submissionFee': submissionFee,
      'currentTips': currentTips,
      'votes': votes,
      'submitterId': submitterId,
      'performerId': performerId,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'tags': tags,
      'isSponsored': isSponsored,
      'sponsorBrand': sponsorBrand,
    };
  }

  double get platformCut => submissionFee * 0.2 + currentTips * 0.5;
  double get performerEarnings => submissionFee * 0.8 + currentTips * 0.5;
}