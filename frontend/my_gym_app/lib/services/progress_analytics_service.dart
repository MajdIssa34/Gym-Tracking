import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProgressAnalyticsService {
  final String baseUrl = "http://localhost:9090/api";

  // 🔹 Fetch Token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); // Retrieves the stored JWT token
  }

  Future<List<String>?> fetchUserExercises(String userId) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/progress-analytics/user/$userId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> exercises = jsonDecode(response.body);

      // 🔹 Extract unique exercise names using a Set
      Set<String> uniqueExercises = exercises
          .map((exercise) => exercise['exerciseName'].toString())
          .toSet();

      return uniqueExercises.toList();
    }
    return null;
  }

  // 🔹 Fetch exercise progress history for a user (WITH BEARER TOKEN)
  Future<List<Map<String, dynamic>>?> fetchExerciseProgress(
      String userId, String exerciseName) async {
    final token = await _getToken();
    if (token == null) {
      print("❌ No token found.");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/exercises/progress/$userId/$exerciseName"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print(
            "❌ Failed to fetch exercise progress. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching exercise progress: $e");
    }

    return null;
  }

  // 🔹 Fetch Best Lift (WITH BEARER TOKEN)
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
