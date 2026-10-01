import 'package:flutter/material.dart';
import '../app.dart';
import '../models/photo.dart';
import '../routes/app_router.dart';
import '../widgets/photo_grid_item.dart';
import '../widgets/resource_view.dart';
import '../widgets/user_avatar.dart';

class AlbumDetailsScreen extends StatefulWidget {
  final AlbumDetailsArgs args;

  const AlbumDetailsScreen({
    super.key,
    required this.args,
  });

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appScope = AppScope.of(context);
      appScope.albumController.loadPhotos(widget.args.album.id);
    });
  }

  void _showPhotoDialog(BuildContext context, Photo photo) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(dialogCtx),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  photo.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    final hue = (photo.id.abs() * 137.508) % 360;
                    final fallback = HSLColor.fromAHSL(1.0, hue, 0.60, 0.45).toColor();

                    return Container(
                      color: fallback,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.broken_image_rounded, size: 48, color: Colors.white70),
                            const SizedBox(height: 8),
                            Text(
                              photo.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                photo.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appScope = AppScope.of(context);
    final album = widget.args.album;
    final author = widget.args.author;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Album Details'),
      ),
      body: CustomScrollView(
        slivers: [
          // Album Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      UserAvatar(
                        user: author,
                        id: album.userId,
                        name: author?.name ?? 'User ${album.userId}',
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author?.name ?? 'User #${album.userId}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Album #${album.id}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    album.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                ],
              ),
            ),
          ),

          // Photos Grid using ResourceView
          SliverFillRemaining(
            child: ResourceView<List<Photo>>(
              controller: appScope.albumController.photosResource,
              onRetry: () => appScope.albumController.loadPhotos(album.id),
              emptyTitle: 'No Photos in Album',
              emptyMessage: 'This album currently has no photos.',
              builder: (context, photos) {
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return PhotoGridItem(
                      photo: photo,
                      onTap: () => _showPhotoDialog(context, photo),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
