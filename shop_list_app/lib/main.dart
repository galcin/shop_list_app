import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/shared/route_constants.dart';

import 'app.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
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
      print('[Splash] Starting database initialization...');
      // Initialize database in background
      final database = AppDatabase.instance;
      await database.ensureInitialized();
      print('[Splash] Database initialization complete');

      // Navigate to main view after initialization
      if (mounted) {
        print('[Splash] Navigating to main view');
        Navigator.of(context).pushReplacementNamed(mainView);
      }
    } catch (e, stackTrace) {
      print('[Splash] Error initializing app: $e');
      print('[Splash] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing app: $e'),
            duration: Duration(seconds: 5),
          ),
        );
        // Still navigate to main view to prevent being stuck
        await Future.delayed(Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(mainView);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
