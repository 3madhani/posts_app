import 'package:flutter/material.dart';
import '../app.dart';
import '../models/post.dart';
import '../routes/app_router.dart';
import '../widgets/post_card.dart';
import '../widgets/resource_view.dart';

class PostsScreen extends StatefulWidget {
  final bool embedded;

  const PostsScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _filterOnlyMine = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreatePostSheet(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Post',
                      style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter post title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: bodyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    hintText: 'What is on your mind?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(sheetCtx);

                    final appScope = AppScope.of(context);
                    final userId = appScope.authController.currentUser?.id ?? 1;

                    final created = await appScope.postController.createPost(
                      title: titleController.text.trim(),
                      body: bodyController.text.trim(),
                      userId: userId,
                    );

                    if (!context.mounted) return;
                    if (created != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post published successfully!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Publish Post'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeletePost(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Are you sure you want to delete "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final appScope = AppScope.of(context);
              final success = await appScope.postController.deletePost(post.id);
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
                  hintText: 'Search posts...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            appScope.postController.setSearchQuery('');
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
                  appScope.postController.setSearchQuery(val);
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilterChip(
                    label: const Text('All Posts'),
                    selected: !_filterOnlyMine,
                    onSelected: (selected) {
                      setState(() {
                        _filterOnlyMine = false;
                        appScope.postController.setFilterUserId(null);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  if (currentUserId != null)
                    FilterChip(
                      label: const Text('My Posts'),
                      selected: _filterOnlyMine,
                      onSelected: (selected) {
                        setState(() {
                          _filterOnlyMine = selected;
                          appScope.postController.setFilterUserId(selected ? currentUserId : null);
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),

        // Posts List with ResourceView
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await appScope.postController.loadPosts(forceRefresh: true);
            },
            child: ResourceView<List<Post>>(
              controller: appScope.postController.postsResource,
              onRetry: () => appScope.postController.loadPosts(forceRefresh: true),
              emptyTitle: 'No Posts Found',
              emptyMessage: 'No posts match your search or filter criteria.',
              builder: (context, _) {
                final displayPosts = appScope.postController.filteredPosts;

                if (displayPosts.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 60),
                      Center(
                        child: Text(
                          'No posts matching search.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: displayPosts.length,
                  itemBuilder: (context, index) {
                    final post = displayPosts[index];
                    final author = appScope.userController.getUserById(post.userId);
                    final isMyPost = currentUserId != null && post.userId == currentUserId;

                    return PostCard(
                      post: post,
                      author: author,
                      onDelete: isMyPost ? () => _confirmDeletePost(context, post) : null,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.postDetails,
                          arguments: PostDetailsArgs(post: post, author: author),
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
                'Explore Posts',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
            )
          : AppBar(
              title: const Text('Posts'),
            ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Post'),
      ),
    );
  }
}
