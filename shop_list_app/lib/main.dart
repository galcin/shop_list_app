import 'package:flutter/material.dart';
import 'package:shop_list_app/ui/route_constants.dart';
import 'package:shop_list_app/service/storage/local_db/app_database.dart';

import 'ui/router.dart' as router;

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ShoppingListApp());
}

class ShoppingListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      onGenerateRoute: router.generateRoute,
      initialRoute: splashView,
    );
  }
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
