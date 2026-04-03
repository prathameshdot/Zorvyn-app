class Challenge {
  final String? id;
  final String name;
  final String description;
  final String? type;
  final int duration; // days
  final int xpReward;
  final String? icon;

  Challenge({
    this.id,
    required this.name,
    required this.description,
    this.type,
    this.duration = 7,
    this.xpReward = 0,
    this.icon,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id']?.toString(),
      name: json['name'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type']?.toString(),
      duration: (json['duration'] ?? json['days'] ?? 7).toInt(),
      xpReward: (json['xpReward'] ?? json['xp_reward'] ?? json['xp'] ?? 0).toInt(),
      icon: json['icon']?.toString(),
    );
  }
}

class UserChallenge {
  final String? id;
  final String? challengeId;
  final String? name;
  final String? description;
  final String status; // active | completed | abandoned
  final int progress;
  final int target;
  final String? joinedAt;

  UserChallenge({
    this.id,
    this.challengeId,
    this.name,
    this.description,
    this.status = 'active',
    this.progress = 0,
    this.target = 7,
    this.joinedAt,
  });

  factory UserChallenge.fromJson(Map<String, dynamic> json) {
    return UserChallenge(
      id: json['id']?.toString(),
      challengeId: json['challengeId']?.toString() ?? json['challenge_id']?.toString(),
      name: json['name'] ?? json['challengeName'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'active',
      progress: (json['progress'] ?? 0).toInt(),
      target: (json['target'] ?? json['duration'] ?? 7).toInt(),
      joinedAt: json['joinedAt']?.toString() ?? json['joined_at']?.toString(),
    );
  }

  double get progressPercent => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
}

class UserXp {
  final int xp;
  final int level;
  final String tier;

  UserXp({this.xp = 0, this.level = 1, this.tier = 'Bronze'});

  factory UserXp.fromJson(Map<String, dynamic> json) {
    final data = json['xp'] is Map ? json['xp'] : json;
    return UserXp(
      xp: (data['xp'] ?? data['totalXp'] ?? 0).toInt(),
      level: (data['level'] ?? 1).toInt(),
      tier: data['tier']?.toString() ?? 'Bronze',
    );
  }
}

class SavingsStreak {
  final int currentStreak;
  final int longestStreak;
  final String? lastCheckin;

  SavingsStreak({this.currentStreak = 0, this.longestStreak = 0, this.lastCheckin});

  factory SavingsStreak.fromJson(Map<String, dynamic> json) {
    final data = json['streak'] ?? json;
    return SavingsStreak(
      currentStreak: (data['currentStreak'] ?? data['current_streak'] ?? data['current'] ?? 0).toInt(),
      longestStreak: (data['longestStreak'] ?? data['longest_streak'] ?? data['longest'] ?? 0).toInt(),
      lastCheckin: data['lastCheckin']?.toString() ?? data['last_checkin']?.toString(),
    );
  }
}
