import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/album.dart';
import '../models/comment.dart';
import '../models/json_parsing.dart';
import '../models/photo.dart';
import '../models/post.dart';
import '../models/user.dart';
import 'api_exception.dart';

class ApiService {
  static const String defaultBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration requestTimeout = Duration(seconds: 15);

  final String baseUrl;
  final http.Client _client;

  ApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client();

  // Helper method for GET requests
  Future<dynamic> _get(String endpoint, [Map<String, String>? queryParameters]) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters,
      );

      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(requestTimeout);

      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException.network(e.message);
    } on http.ClientException catch (e) {
      throw ApiException.network(e.message);
    } on TimeoutException {
      throw ApiException.network('Request timed out. Please try again.');
    } on FormatException catch (e) {
      throw ApiException.format(e.message);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown(e.toString());
    }
  }

  // Helper method for POST requests
  Future<dynamic> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(requestTimeout);

      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException.network(e.message);
    } on http.ClientException catch (e) {
      throw ApiException.network(e.message);
    } on TimeoutException {
      throw ApiException.network('Request timed out. Please try again.');
    } on FormatException catch (e) {
      throw ApiException.format(e.message);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown(e.toString());
    }
  }

  // Helper method for DELETE requests
  Future<dynamic> _delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client.delete(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(requestTimeout);

      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException.network(e.message);
    } on http.ClientException catch (e) {
      throw ApiException.network(e.message);
    } on TimeoutException {
      throw ApiException.network('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown(e.toString());
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    switch (response.statusCode) {
      case 400:
        throw ApiException.badRequest('Bad request: ${response.statusCode}');
      case 401:
      case 403:
        throw ApiException.unauthorized('Unauthorized: ${response.statusCode}');
      case 404:
        throw ApiException.notFound('Resource not found (404)');
      case 500:
      case 502:
      case 503:
        throw ApiException.serverError('Server error: ${response.statusCode}', response.statusCode);
      default:
        throw ApiException('Failed request with status code: ${response.statusCode}', statusCode: response.statusCode);
    }
  }

  // Users
  Future<List<User>> getUsers() async {
    final data = await _get('/users');
    return JsonParsing.parseList(data, User.fromJson);
  }

  Future<User> getUser(int id) async {
    final data = await _get('/users/$id');
    return User.fromJson(JsonParsing.asMap(data));
  }

  // Posts
  Future<List<Post>> getPosts({int? userId}) async {
    final query = userId != null ? {'userId': userId.toString()} : null;
    final data = await _get('/posts', query);
    return JsonParsing.parseList(data, Post.fromJson);
  }

  Future<Post> getPost(int id) async {
    final data = await _get('/posts/$id');
    return Post.fromJson(JsonParsing.asMap(data));
  }

  Future<List<Comment>> getComments(int postId) async {
    final data = await _get('/posts/$postId/comments');
    return JsonParsing.parseList(data, Comment.fromJson);
  }

  Future<Post> createPost({
    required int userId,
    required String title,
    required String body,
  }) async {
    final data = await _post('/posts', {
      'userId': userId,
      'title': title,
      'body': body,
    });
    return Post.fromJson(JsonParsing.asMap(data));
  }

  Future<bool> deletePost(int id) async {
    await _delete('/posts/$id');
    return true;
  }

  // Albums
  Future<List<Album>> getAlbums({int? userId}) async {
    final query = userId != null ? {'userId': userId.toString()} : null;
    final data = await _get('/albums', query);
    return JsonParsing.parseList(data, Album.fromJson);
  }

  Future<Album> getAlbum(int id) async {
    final data = await _get('/albums/$id');
    return Album.fromJson(JsonParsing.asMap(data));
  }

  // Photos
  Future<List<Photo>> getPhotos(int albumId) async {
    final data = await _get('/albums/$albumId/photos');
    return JsonParsing.parseList(data, Photo.fromJson);
  }

  void dispose() {
    _client.close();
  }
}
