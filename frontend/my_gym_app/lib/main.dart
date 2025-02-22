import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gym_app/screens/register_screen.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures Flutter is initialized properly
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Retrieve token

      print("DEBUG: Token Retrieved: $token"); // Debug print

      setState(() {
        _isAuthenticated = (token != null &&
            token.isNotEmpty); // Ensure it's always true/false
        _isLoading = false;
      });
    } catch (e) {
      print("DEBUG: Error retrieving token: $e");
      setState(() {
        _isAuthenticated = false; // Fail-safe if SharedPreferences fails
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("DEBUG: Navigating to: ${_isAuthenticated ? '/home' : '/login'}");
    print(
        "DEBUG: Safe Initial Route: ${_isAuthenticated ? '/home' : '/login'}");

    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()), // Loading screen
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _isAuthenticated
          ? HomeScreen()
          : LoginScreen(), // 🔥 Directly setting `home`
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}
