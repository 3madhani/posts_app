import 'package:flutter/foundation.dart';
import '../models/album.dart';
import '../models/photo.dart';
import '../services/api_service.dart';
import 'resource_controller.dart';

class AlbumController extends ChangeNotifier {
  final ApiService _apiService;
  final ResourceController<List<Album>> albumsResource = ResourceController<List<Album>>();
  final ResourceController<List<Photo>> photosResource = ResourceController<List<Photo>>();

  String _searchQuery = '';
  int? _filterUserId;

  AlbumController({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    albumsResource.addListener(notifyListeners);
    photosResource.addListener(notifyListeners);
  }

  String get searchQuery => _searchQuery;
  int? get filterUserId => _filterUserId;

  List<Album> get allAlbums => albumsResource.data ?? const [];

  List<Album> get filteredAlbums {
    var list = allAlbums;
    if (_filterUserId != null) {
      list = list.where((a) => a.userId == _filterUserId).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((a) => a.title.toLowerCase().contains(query)).toList();
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

  Future<void> loadAlbums({int? userId, bool forceRefresh = false}) async {
    if (!forceRefresh && albumsResource.hasData && albumsResource.data!.isNotEmpty) {
      return;
    }
    await albumsResource.execute(() => _apiService.getAlbums(userId: userId));
  }

  Future<void> loadPhotos(int albumId) async {
    await photosResource.execute(() => _apiService.getPhotos(albumId));
  }

  @override
  void dispose() {
    albumsResource.removeListener(notifyListeners);
    photosResource.removeListener(notifyListeners);
    albumsResource.dispose();
    photosResource.dispose();
    super.dispose();
  }
}
