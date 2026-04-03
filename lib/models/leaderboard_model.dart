class LeaderboardEntry {
  final String? userId;
  final String name;
  final int rank;
  final double score;

  LeaderboardEntry({
    this.userId,
    required this.name,
    this.rank = 0,
    this.score = 0,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId']?.toString() ?? json['id']?.toString(),
      name: json['name'] ?? json['userName'] ?? 'Unknown',
      rank: (json['rank'] ?? json['position'] ?? 0).toInt(),
      score: (json['score'] ?? json['points'] ?? 0).toDouble(),
    );
  }
}
