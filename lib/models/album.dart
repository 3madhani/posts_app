import 'json_parsing.dart';

class Album {
  final int id;
  final int userId;
  final String title;

  const Album({
    required this.id,
    required this.userId,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: JsonParsing.asInt(json['id']),
      userId: JsonParsing.asInt(json['userId']),
      title: JsonParsing.asString(json['title']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
    };
  }

  Album copyWith({
    int? id,
    int? userId,
    String? title,
  }) {
    return Album(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
    );
  }

  @override
  String toString() => 'Album(id: $id, userId: $userId, title: $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ title.hashCode;
}
