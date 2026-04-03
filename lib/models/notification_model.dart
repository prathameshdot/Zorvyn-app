class AppNotification {
  final String? id;
  final String? userId;
  final String title;
  final String message;
  final String? dialog;
  final bool read;
  final String? createdAt;

  AppNotification({
    this.id,
    this.userId,
    required this.title,
    required this.message,
    this.dialog,
    this.read = false,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? '',
      dialog: json['dialog']?.toString(),
      read: json['read'] == true,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
    );
  }
}
