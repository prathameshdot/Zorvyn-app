class User {
  final String? id;
  final String email;
  final String name;
  final String? createdAt;

  User({this.id, required this.email, required this.name, this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'email': email,
        'name': name,
      };

  User copyWith({String? id, String? email, String? name}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt,
    );
  }
}
