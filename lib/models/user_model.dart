class AppUser {
  final String id;
  final String email;
  final String username;
  final String? profileImageUrl;
  final DateTime dateOfBirth;
  final bool isVerified;
  final double totalEarnings;
  final int completedDares;
  final int failedDares;
  final List<String> followers;
  final List<String> following;
  final bool isPremium;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    this.profileImageUrl,
    required this.dateOfBirth,
    this.isVerified = false,
    this.totalEarnings = 0.0,
    this.completedDares = 0,
    this.failedDares = 0,
    this.followers = const [],
    this.following = const [],
    this.isPremium = false,
    required this.createdAt,
  });

  bool get isAdult {
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      return age - 1 >= 18;
    }
    return age >= 18;
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'] ?? 0),
      isVerified: map['isVerified'] ?? false,
      totalEarnings: (map['totalEarnings'] ?? 0.0).toDouble(),
      completedDares: map['completedDares'] ?? 0,
      failedDares: map['failedDares'] ?? 0,
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      isPremium: map['isPremium'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'isVerified': isVerified,
      'totalEarnings': totalEarnings,
      'completedDares': completedDares,
      'failedDares': failedDares,
      'followers': followers,
      'following': following,
      'isPremium': isPremium,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}