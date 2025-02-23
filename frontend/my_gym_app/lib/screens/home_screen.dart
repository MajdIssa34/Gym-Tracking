import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gym_app/screens/wokrout_screen.dart';
import '../services/workout_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WorkoutService _workoutService = WorkoutService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> workouts = [];
  Map<int, List<Map<String, dynamic>>> workoutExercises = {};
  bool _loading = true;
  String userName = "User"; // Placeholder
  double totalWeightLifted = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  void _fetchWorkouts() async {
    final fetchedWorkouts = await _workoutService.fetchWorkouts();
    final userInfo = await _authService.getUserInfo();

    if (fetchedWorkouts.isNotEmpty) {
      // Get the last workout's ID
      int lastWorkoutId = fetchedWorkouts.first['id'];
      _fetchWorkoutSummary(lastWorkoutId);
    }

    setState(() {
      workouts = fetchedWorkouts.take(3).toList(); // Show last 3 workouts
      userName = userInfo['name'] ?? "User";
      _loading = false;
    });
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _fetchWorkoutSummary(int workoutId) async {
    final summary = await _workoutService.fetchWorkoutSummary(workoutId);
    if (summary != null) {
      setState(() {
        totalWeightLifted = summary['totalWeightLifted'];
      });
    }
  }

  // 🔹 Start New Workout Flow
  void _startNewWorkout() async {
    TextEditingController _notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "New Workout",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: "Workout Notes (e.g., Leg Day, Push Day)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _createWorkout(_notesController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  "Create Workout",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createWorkout(String notes) async {
    final userInfo = await _authService.getUserInfo();

    if (userInfo['id'] == null) {
      _showSnackBar("User not found!", Colors.red);
      return;
    }

    final workout = {
      "user": {
        "id": userInfo['id'],
        "name": userInfo['name'],
        "email": userInfo['email'],
      },
      "notes": notes
    };

    final workoutId = await _workoutService.createWorkout(workout);

    if (workoutId != null) {
      _showSnackBar("Workout Created! 🏋️", Colors.green);
      _fetchWorkouts();

      // ✅ Prompt user to add exercises
      _showAddExerciseModal(workoutId);
    } else {
      _showSnackBar("Failed to create workout", Colors.red);
    }
  }

  void _showAddExerciseModal(int workoutId) {
    TextEditingController _exerciseNameController = TextEditingController();
    TextEditingController _setsController = TextEditingController();
    TextEditingController _repsController = TextEditingController();
    TextEditingController _weightController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Exercise",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Exercise Name
              TextField(
                controller: _exerciseNameController,
                decoration: InputDecoration(
                  labelText: "Exercise Name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),

              // Sets
              TextField(
                controller: _setsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Sets",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),

              // Reps
              TextField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Reps",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),

              // Weight
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Weight (kg)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),

              // ✅ Add Exercise Button
              ElevatedButton(
                onPressed: () async {
                  if (_exerciseNameController.text.isEmpty ||
                      _setsController.text.isEmpty ||
                      _repsController.text.isEmpty ||
                      _weightController.text.isEmpty) {
                    _showSnackBar("Please fill all fields", Colors.red);
                    return;
                  }

                  int sets = int.tryParse(_setsController.text) ?? 0;
                  int reps = int.tryParse(_repsController.text) ?? 0;
                  double weight =
                      double.tryParse(_weightController.text) ?? 0.0;

                  if (sets <= 0 || reps <= 0 || weight < 0) {
                    _showSnackBar("Invalid values!", Colors.red);
                    return;
                  }

                  Navigator.pop(context); // Close modal

                  await _addExerciseToWorkout(workoutId,
                      _exerciseNameController.text, sets, reps, weight);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  "Add Exercise",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addExerciseToWorkout(int workoutId, String exerciseName, int sets, int reps, double weight) async {
  final exercise = {
    "workoutId": workoutId, // Correct format
    "exerciseName": exerciseName,
    "sets": sets,
    "reps": reps,
    "weight": weight
  };

  bool success = await _workoutService.addExercise(exercise);

  if (success) {
    _showSnackBar("Exercise Added! 💪", Colors.green);
    _fetchWorkouts(); // Refresh workouts list
  } else {
    _showSnackBar("Failed to add exercise", Colors.red);
  }
}


  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // 🔹 App Bar
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "🏋️ My Gym",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **🏋️ Welcome Header**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back, $userName!",
                      style: GoogleFonts.poppins(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "📅 ${DateTime.now().toLocal().toString().split(' ')[0]}",
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueAccent,
                  child:
                      const Icon(Icons.person, size: 35, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // **📊 Quick Stats**
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Column(
                children: [
                  Text("📊 Quick Stats",
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statBox("🏆 Best Lift", "Squat 140kg"),
                      _statBox("📆 Workouts", workouts.length.toString()),
                      _statBox("💪 Last Workout",
                          "${totalWeightLifted.toStringAsFixed(1)} kg"), // Placeholder
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // **📜 Recent Workouts & Add Button**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "📜 Recent Workouts",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _startNewWorkout,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Start New Workout",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white)),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _loading
                ? const Center(child: CircularProgressIndicator())
                : workouts.isNotEmpty
                    ? Column(
                        children: workouts.map((workout) {
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            child: ListTile(
                              title: Text(
                                "${workout['notes'] ?? 'Workout'} - ${workout['createdAt'] ?? 'Unknown Date'}",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold),
                              ),
                              leading: const Icon(Icons.fitness_center,
                                  color: Colors.blueAccent),
                            ),
                          );
                        }).toList(),
                      )
                    : Text("No recent workouts.",
                        style: GoogleFonts.poppins(fontSize: 16)),

            const SizedBox(height: 20),

            // 🔹 See All Workouts Button
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const WorkoutsScreen()));
                },
                child: Text(
                  "See All Workouts →",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String title, String value) {
    return Column(
      children: [
        Text(value,
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
