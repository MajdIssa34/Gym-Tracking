import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
 
class ProgressAnalyticsService {
  
  final String baseUrl =
      "http://localhost:9090/api";

  
  // 🔹 Fetch Token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); // ✅ Fixed from "auth_token"
  }

}