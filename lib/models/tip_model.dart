class Tip {
  final int? id;
  final String title;
  final String content;
  final String? category;
  final String? icon;
  final bool bookmarked;

  Tip({
    this.id,
    required this.title,
    required this.content,
    this.category,
    this.icon,
    this.bookmarked = false,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      title: json['title'] ?? '',
      content: json['content'] ?? json['description'] ?? json['text'] ?? '',
      category: json['category']?.toString(),
      icon: json['icon']?.toString(),
      bookmarked: json['bookmarked'] == true,
    );
  }

  Tip copyWith({bool? bookmarked}) {
    return Tip(
      id: id,
      title: title,
      content: content,
      category: category,
      icon: icon,
      bookmarked: bookmarked ?? this.bookmarked,
    );
  }
}
