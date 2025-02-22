import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  Map<int, List<Map<String, dynamic>>> workoutExercises = {}; // Map to store exercises per workout
  bool _loading = true;
  Set<int> _expandedWorkoutIds = {}; // Track expanded workouts

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  // 🔹 Fetch Workouts
  void _fetchWorkouts() async {
    print("🔵 Fetching workouts...");
    final fetchedWorkouts = await _workoutService.fetchWorkouts();
    print("✅ Workouts received: $fetchedWorkouts");

    setState(() {
      workouts = fetchedWorkouts;
      _loading = false;
    });
  }

  // 🔹 Fetch Exercises for a Workout
  void _fetchExercises(int workoutId) async {
    if (workoutExercises.containsKey(workoutId)) return; // Don't fetch twice
    print("🔵 Fetching exercises for workout ID: $workoutId");

    final fetchedExercises = await _workoutService.fetchExercises(workoutId);
    print("✅ Exercises received for workout $workoutId: $fetchedExercises");

    setState(() {
      workoutExercises[workoutId] = fetchedExercises;
    });
  }

  // 🔹 Logout
  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 App Bar with Logout Button
      appBar: AppBar(
        title: Text(
          "🏋️ My Workouts",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : workouts.isNotEmpty
                ? ListView.builder(
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      final workoutId = workout['id'];

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ExpansionTile(
                          title: Text(
                            "Workout ${index + 1} - ${workout['createdAt'] ?? 'Unknown Date'}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.fitness_center,
                              color: Colors.blueAccent),
                          initiallyExpanded:
                              _expandedWorkoutIds.contains(workoutId),
                          onExpansionChanged: (expanded) {
                            setState(() {
                              if (expanded) {
                                _expandedWorkoutIds.add(workoutId);
                                _fetchExercises(workoutId);
                              } else {
                                _expandedWorkoutIds.remove(workoutId);
                              }
                            });
                          },
                          children: workoutExercises[workoutId] != null
                              ? workoutExercises[workoutId]!.isNotEmpty
                                  ? workoutExercises[workoutId]!
                                      .map<Widget>((exercise) {
                                      return ListTile(
                                        leading: const Icon(
                                            Icons.fitness_center,
                                            color: Colors.blue),
                                        title: Text(
                                          exercise['exerciseName'] ??
                                              'Unnamed Exercise',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          "${exercise['sets'] ?? 0} Sets - ${exercise['reps'] ?? 0} Reps - ${exercise['weight'] ?? 0} kg",
                                          style: GoogleFonts.poppins(),
                                        ),
                                      );
                                    }).toList()
                                  : [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text("No exercises recorded.",
                                            style: GoogleFonts.poppins()),
                                      )
                                    ]
                              : [
                                  const Center(
                                      child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(),
                                  ))
                                ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text("No recent workouts.",
                        style: GoogleFonts.poppins(fontSize: 16))),
      ),
    );
  }
}
