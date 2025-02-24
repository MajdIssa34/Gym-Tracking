import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProgressAnalyticsService {
  final String baseUrl = "http://localhost:9090/api";

  // 🔹 Fetch Token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // 🔹 Fetch Best Lift
  Future<Map<String, dynamic>?> fetchBestLift(String userId) async {
    final token = await _getToken();
    if (token == null) {
      print("❌ No token found.");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/personal-records/user/$userId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> records = jsonDecode(response.body);

        if (records.isNotEmpty) {
          Map<String, dynamic> bestExercise = records.reduce((a, b) {
            return a['bestWeight'] > b['bestWeight'] ? a : b;
          });

          return bestExercise;
        }
      } else {
        print("❌ Failed to fetch best lift. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching best lift: $e");
    }

    return null;
  }
}
