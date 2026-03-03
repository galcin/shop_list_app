import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/core/navigation/app_route.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';

import 'app.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise file logger first so all subsequent errors are captured.
  await AppLogger.instance.init();

  // Capture Flutter framework errors (widget build errors, etc.).
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.instance.error(
      'FlutterError: ${details.exceptionAsString()}',
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  // Capture async / isolate errors that escape Flutter's error handler.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.instance.error(
      'Unhandled platform error: $error',
      error: error,
      stackTrace: stack,
    );
    return false; // let the platform handle it too
  };

  runApp(const ProviderScope(child: App()));
}

// Splash screen that initializes database in background
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defer initialization until after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      AppLogger.instance.info('[Splash] Starting database initialization...');
      final database = AppDatabase.instance;
      await database.ensureInitialized();
      AppLogger.instance.info('[Splash] Database initialization complete');

      if (mounted) {
        AppLogger.instance.info('[Splash] Navigating to main shell');
        context.go(AppRoute.shopping.path);
      }
    } catch (e, stackTrace) {
      AppLogger.instance.error(
        '[Splash] Error initializing app',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing app: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go(AppRoute.shopping.path);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
