import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutService {
  final String baseUrl =
      "http://localhost:9090/api"; // ✅ Update this to your real API URL

  // 🔹 Fetch Token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); // ✅ Fixed from "auth_token"
  }

  // 🔹 Fetch User ID
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userIdString = prefs.getString("user_id");

    if (userIdString == null) {
      print("❌ No user_id found in SharedPreferences");
      return null;
    }

    int? userId = int.tryParse(userIdString);
    if (userId == null) {
      print("❌ Invalid user_id format in SharedPreferences: $userIdString");
    }
    return userId;
  }

  // 🔹 Fetch Workouts for User
  Future<List<Map<String, dynamic>>> fetchWorkouts() async {
    final token = await _getToken();
    final userId = await _getUserId();

    if (token == null || userId == null) {
      print("❌ No token or user ID found!");
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/workouts/user/$userId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> jsonResponse =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        print("✅ Workouts Fetched: $jsonResponse");
        return jsonResponse;
      } else {
        print("❌ Failed to fetch workouts. Status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Workout Fetch Error: $e");
      return [];
    }
  }

  // 🔹 Fetch Exercises for a Workout
  Future<List<Map<String, dynamic>>> fetchExercises(int workoutId) async {
    final token = await _getToken();
    if (token == null) {
      print("❌ No token found!");
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/exercises/workout/$workoutId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> jsonResponse =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        print("✅ Fetched Exercises for Workout $workoutId: $jsonResponse");
        return jsonResponse;
      } else {
        print("❌ Failed to fetch exercises. Status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Exercise Fetch Error: $e");
      return [];
    }
  }

  // 🔹 Fetch Personal Records
  Future<List<Map<String, dynamic>>> fetchPersonalRecords() async {
    final token = await _getToken();
    final userId = await _getUserId();
    if (token == null || userId == null) return [];

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/personal-records/user/$userId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> jsonResponse =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        print("✅ Fetched Personal Records: $jsonResponse");
        return jsonResponse;
      } else {
        print(
            "❌ Failed to fetch personal records. Status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Personal Records Fetch Error: $e");
      return [];
    }
  }

  // 🔹 Fetch Progress Analytics
  Future<List<Map<String, dynamic>>> fetchProgressAnalytics() async {
    final token = await _getToken();
    final userId = await _getUserId();
    if (token == null || userId == null) return [];

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/progress-analytics/user/$userId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> jsonResponse =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        print("✅ Fetched Progress Analytics: $jsonResponse");
        return jsonResponse;
      } else {
        print(
            "❌ Failed to fetch progress analytics. Status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Progress Analytics Fetch Error: $e");
      return [];
    }
  }

  // 🔹 Start a New Workout
  Future<bool> startNewWorkout() async {
    final token = await _getToken();
    final userId = await _getUserId();
    if (token == null || userId == null) return false;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/workouts"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 201) {
        print("✅ New Workout Created Successfully!");
        return true;
      } else {
        print("❌ Failed to start workout. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Start Workout Error: $e");
      return false;
    }
  }
}
