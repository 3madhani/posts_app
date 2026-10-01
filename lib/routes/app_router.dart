import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../views/album_details_screen.dart';
import '../views/albums_screen.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../views/post_details_screen.dart';
import '../views/posts_screen.dart';

class PostDetailsArgs {
  final Post post;
  final User? author;

  const PostDetailsArgs({
    required this.post,
    this.author,
  });
}

class AlbumDetailsArgs {
  final Album album;
  final User? author;

  const AlbumDetailsArgs({
    required this.album,
    this.author,
  });
}

class AppRouter {
  AppRouter._();

  static const String login = '/login';
  static const String home = '/home';
  static const String posts = '/posts';
  static const String postDetails = '/post-details';
  static const String albums = '/albums';
  static const String albumDetails = '/album-details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );

      case posts:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const PostsScreen(),
        );

      case postDetails:
        final args = settings.arguments as PostDetailsArgs;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PostDetailsScreen(args: args),
        );

      case albums:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AlbumsScreen(),
        );

      case albumDetails:
        final args = settings.arguments as AlbumDetailsArgs;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => AlbumDetailsScreen(args: args),
        );

      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
