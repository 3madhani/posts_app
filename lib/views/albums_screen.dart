import 'package:flutter/material.dart';
import '../app.dart';
import '../models/album.dart';
import '../routes/app_router.dart';
import '../widgets/album_card.dart';
import '../widgets/resource_view.dart';

class AlbumsScreen extends StatefulWidget {
  final bool embedded;

  const AlbumsScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _filterOnlyMine = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appScope = AppScope.of(context);
    final currentUserId = appScope.authController.currentUser?.id;

    final body = Column(
      children: [
        // Search & Filter header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search albums...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            appScope.albumController.setSearchQuery('');
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  appScope.albumController.setSearchQuery(val);
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilterChip(
                    label: const Text('All Albums'),
                    selected: !_filterOnlyMine,
                    onSelected: (selected) {
                      setState(() {
                        _filterOnlyMine = false;
                        appScope.albumController.setFilterUserId(null);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  if (currentUserId != null)
                    FilterChip(
                      label: const Text('My Albums'),
                      selected: _filterOnlyMine,
                      onSelected: (selected) {
                        setState(() {
                          _filterOnlyMine = selected;
                          appScope.albumController.setFilterUserId(selected ? currentUserId : null);
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),

        // Albums List with ResourceView
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await appScope.albumController.loadAlbums(forceRefresh: true);
            },
            child: ResourceView<List<Album>>(
              controller: appScope.albumController.albumsResource,
              onRetry: () => appScope.albumController.loadAlbums(forceRefresh: true),
              emptyTitle: 'No Albums Found',
              emptyMessage: 'No albums match your search or filter criteria.',
              builder: (context, _) {
                final displayAlbums = appScope.albumController.filteredAlbums;

                if (displayAlbums.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 60),
                      Center(
                        child: Text(
                          'No albums matching search.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: displayAlbums.length,
                  itemBuilder: (context, index) {
                    final album = displayAlbums[index];
                    final author = appScope.userController.getUserById(album.userId);

                    return AlbumCard(
                      album: album,
                      author: author,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.albumDetails,
                          arguments: AlbumDetailsArgs(album: album, author: author),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: widget.embedded
          ? AppBar(
              title: const Text(
                'Photo Albums',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
            )
          : AppBar(
              title: const Text('Albums'),
            ),
      body: body,
    );
  }
}
