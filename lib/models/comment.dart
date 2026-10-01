import 'json_parsing.dart';

class Comment {
  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  const Comment({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: JsonParsing.asInt(json['id']),
      postId: JsonParsing.asInt(json['postId']),
      name: JsonParsing.asString(json['name']),
      email: JsonParsing.asString(json['email']),
      body: JsonParsing.asString(json['body']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'name': name,
      'email': email,
      'body': body,
    };
  }

  Comment copyWith({
    int? id,
    int? postId,
    String? name,
    String? email,
    String? body,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      name: name ?? this.name,
      email: email ?? this.email,
      body: body ?? this.body,
    );
  }

  @override
  String toString() => 'Comment(id: $id, postId: $postId, name: $name, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          postId == other.postId &&
          name == other.name &&
          email == other.email &&
          body == other.body;

  @override
  int get hashCode =>
      id.hashCode ^
      postId.hashCode ^
      name.hashCode ^
      email.hashCode ^
      body.hashCode;
}
