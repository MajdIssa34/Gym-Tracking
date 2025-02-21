import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:9090/api/auth'));

  // 🔹 Login Function
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {'email': email, 'password': password});

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final user = response.data['user']; // User DTO with id, name, email

        // Store Token and User Info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_id', user['id'].toString());
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_email', user['email']);

        return user; // Return user data for further use
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  // 🔹 Register Function
  Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        final token = response.data['token'];
        final user = response.data['user'];

        // Store Token and User Info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_id', user['id'].toString());
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_email', user['email']);

        return user;
      }
    } catch (e) {
      print('Register error: $e');
    }
    return null;
  }

  // 🔹 Logout Function
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
  }

  // 🔹 Get Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 🔹 Get User Info
  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('user_id'),
      'name': prefs.getString('user_name'),
      'email': prefs.getString('user_email'),
    };
  }

  // 🔹 Add Auth Header to Requests
  Future<Dio> getDioWithAuth() async {
    final token = await getToken();
    _dio.options.headers["Authorization"] = "Bearer $token";
    return _dio;
  }
}
