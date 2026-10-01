import 'package:flutter/material.dart';
import 'controllers/album_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/post_controller.dart';
import 'controllers/user_controller.dart';
import 'routes/app_router.dart';
import 'services/api_service.dart';

class AppScope extends InheritedWidget {
  final ApiService apiService;
  final AuthController authController;
  final UserController userController;
  final PostController postController;
  final AlbumController albumController;

  const AppScope({
    super.key,
    required this.apiService,
    required this.authController,
    required this.userController,
    required this.postController,
    required this.albumController,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in the current context');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) => false;
}

class PostsApp extends StatefulWidget {
  final ApiService? apiService;
  final AuthController? authController;
  final UserController? userController;
  final PostController? postController;
  final AlbumController? albumController;

  const PostsApp({
    super.key,
    this.apiService,
    this.authController,
    this.userController,
    this.postController,
    this.albumController,
  });

  @override
  State<PostsApp> createState() => _PostsAppState();
}

class _PostsAppState extends State<PostsApp> {
  late final ApiService _apiService;
  late final AuthController _authController;
  late final UserController _userController;
  late final PostController _postController;
  late final AlbumController _albumController;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _authController = widget.authController ?? AuthController(apiService: _apiService);
    _userController = widget.userController ?? UserController(apiService: _apiService);
    _postController = widget.postController ?? PostController(apiService: _apiService);
    _albumController = widget.albumController ?? AlbumController(apiService: _apiService);
  }

  @override
  void dispose() {
    _albumController.dispose();
    _postController.dispose();
    _userController.dispose();
    _authController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3F51B5);

    return AppScope(
      apiService: _apiService,
      authController: _authController,
      userController: _userController,
      postController: _postController,
      albumController: _albumController,
      child: MaterialApp(
        title: 'PostsApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        initialRoute: AppRouter.login,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
