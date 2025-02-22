import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _redirecting = false;

  void _login() async {
    setState(() => _loading = true);

    final user = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _loading = false);

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);

      _showSnackBar("Login successful! 🎉 Redirecting...", Colors.green);

      setState(() => _redirecting = true);

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _redirecting = false);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      });
    } else {
      _showSnackBar("Login failed! Check your credentials. ❌", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // **🔹 Gradient Background**
        Container(
          decoration: const BoxDecoration(color: Colors.white),
        ),

        Scaffold(
          backgroundColor: Colors.transparent, // Make Scaffold transparent
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // **🔹 App Logo Placeholder**
                    SizedBox(
                      height: 200, 
                      width: 200, 
                      child: Image.asset('assets/images/Logo.png',
                          fit: BoxFit.contain),
                    ),

                    const SizedBox(height: 20),

                    // **🔹 Login Form**
                    Container(
                      height: 270,
                      width: 400,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        // Use a modified gradient with a slightly less opaque gradient overlay
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(204, 157, 112,
                                206), // Note the 'CC' for ~80% opacity
                            Color.fromARGB(204, 86, 130, 207),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                        // Optionally, you can add a subtle white border to further separate it from the background:
                        border: Border.all(color: Colors.white70, width: 1),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle:
                                  GoogleFonts.poppins(color: Colors.white),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle:
                                  GoogleFonts.poppins(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          _loading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 40),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                  child: Text("Login",
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                                context, '/register'),
                            child: Text("Don't have an account? Register",
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // **🔹 Fullscreen Loading Overlay**
        if (_redirecting)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    "Logging in... Please wait",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
