import 'json_parsing.dart';

class Photo {
  final int id;
  final int albumId;
  final String title;
  final String url;
  final String thumbnailUrl;

  const Photo({
    required this.id,
    required this.albumId,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: JsonParsing.asInt(json['id']),
      albumId: JsonParsing.asInt(json['albumId']),
      title: JsonParsing.asString(json['title']),
      url: JsonParsing.asString(json['url']),
      thumbnailUrl: JsonParsing.asString(json['thumbnailUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'albumId': albumId,
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  Photo copyWith({
    int? id,
    int? albumId,
    String? title,
    String? url,
    String? thumbnailUrl,
  }) {
    return Photo(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      title: title ?? this.title,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  @override
  String toString() => 'Photo(id: $id, albumId: $albumId, title: $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Photo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          albumId == other.albumId &&
          title == other.title &&
          url == other.url &&
          thumbnailUrl == other.thumbnailUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      albumId.hashCode ^
      title.hashCode ^
      url.hashCode ^
      thumbnailUrl.hashCode;
}
