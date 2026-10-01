import 'package:flutter/foundation.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import 'resource_controller.dart';

class PostController extends ChangeNotifier {
  final ApiService _apiService;
  final ResourceController<List<Post>> postsResource = ResourceController<List<Post>>();
  final ResourceController<List<Comment>> commentsResource = ResourceController<List<Comment>>();

  String _searchQuery = '';
  int? _filterUserId;

  PostController({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    postsResource.addListener(notifyListeners);
    commentsResource.addListener(notifyListeners);
  }

  String get searchQuery => _searchQuery;
  int? get filterUserId => _filterUserId;

  List<Post> get allPosts => postsResource.data ?? const [];

  List<Post> get filteredPosts {
    var list = allPosts;
    if (_filterUserId != null) {
      list = list.where((p) => p.userId == _filterUserId).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(query) ||
              p.body.toLowerCase().contains(query))
          .toList();
    }
    return list;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterUserId(int? userId) {
    _filterUserId = userId;
    notifyListeners();
  }

  Future<void> loadPosts({int? userId, bool forceRefresh = false}) async {
    if (!forceRefresh && postsResource.hasData && postsResource.data!.isNotEmpty) {
      return;
    }
    await postsResource.execute(() => _apiService.getPosts(userId: userId));
  }

  Future<void> loadComments(int postId) async {
    await commentsResource.execute(() => _apiService.getComments(postId));
  }

  Future<Post?> createPost({
    required String title,
    required String body,
    required int userId,
  }) async {
    try {
      final newPost = await _apiService.createPost(
        userId: userId,
        title: title,
        body: body,
      );

      // Prepend to current list for immediate feedback
      final currentList = List<Post>.from(postsResource.data ?? []);
      currentList.insert(0, newPost);
      postsResource.setData(currentList);
      notifyListeners();
      return newPost;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deletePost(int id) async {
    try {
      final success = await _apiService.deletePost(id);
      if (success) {
        final currentList = List<Post>.from(postsResource.data ?? []);
        currentList.removeWhere((p) => p.id == id);
        postsResource.setData(currentList);
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    postsResource.removeListener(notifyListeners);
    commentsResource.removeListener(notifyListeners);
    postsResource.dispose();
    commentsResource.dispose();
    super.dispose();
  }
}
