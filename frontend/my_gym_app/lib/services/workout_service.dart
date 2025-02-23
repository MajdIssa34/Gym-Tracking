import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutService {
  final String baseUrl = "http://localhost:9090/api"; // ✅ Your API URL

  // 🔹 Fetch Token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
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
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
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
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/exercises/workout/$workoutId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print("❌ Failed to fetch exercises. Status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Exercise Fetch Error: $e");
      return [];
    }
  }

  // 🔹 Fetch Workout Summary
  Future<Map<String, dynamic>?> fetchWorkoutSummary(int workoutId) async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/exercises/workout/$workoutId/summary"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ Failed to fetch workout summary. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Workout Summary Fetch Error: $e");
      return null;
    }
  }

  // 🔹 Create a new workout
  Future<int?> createWorkout(Map<String, dynamic> workout) async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/workouts"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode(workout),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['id']; // Return workout ID
      } else {
        print("❌ Failed to create workout. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Create Workout Error: $e");
      return null;
    }
  }

  // 🔹 Add Exercise to a Workout
  Future<bool> addExercise(Map<String, dynamic> exercise) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/exercises"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode(exercise),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Exercise Added: ${response.body}");
        return true;
      } else {
        print("❌ Failed to add exercise. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error Adding Exercise: $e");
      return false;
    }
  }

  // 🔹 Delete Workout
  Future<bool> deleteWorkout(int workoutId) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/workouts/$workoutId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        print("✅ Workout Deleted: $workoutId");
        return true;
      } else {
        print("❌ Failed to delete workout. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error Deleting Workout: $e");
      return false;
    }
  }

  // 🔹 Delete Exercise
  Future<bool> deleteExercise(int exerciseId) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/exercises/$exerciseId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        print("✅ Exercise Deleted: $exerciseId");
        return true;
      } else {
        print("❌ Failed to delete exercise. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error Deleting Exercise: $e");
      return false;
    }
  }

  // 🔹 Start a New Workout
  Future<int?> startNewWorkout(String notes) async {
    final userId = await _getUserId();
    final userInfo = {
      "id": userId,
      "name": "Majd Issa",
      "email": "majd@gmail.com"
    };

    if (userId == null) return null;

    final workoutData = {"user": userInfo, "notes": notes};

    return await createWorkout(workoutData);
  }
}
