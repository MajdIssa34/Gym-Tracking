import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/workout_service.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  @override
  _WorkoutsScreenState createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final WorkoutService _workoutService = WorkoutService();

  List<Map<String, dynamic>> workouts = [];
  Map<int, List<Map<String, dynamic>>> workoutExercises = {};
  Map<int, Map<String, dynamic>> workoutSummaries = {};
  bool _loading = true;
  Set<int> _expandedWorkoutIds = {};

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  void _fetchWorkouts() async {
    final fetchedWorkouts = await _workoutService.fetchWorkouts();
    for (var workout in fetchedWorkouts) {
      int workoutId = workout['id'];
      _fetchExercises(workoutId);
    }

    setState(() {
      workouts = fetchedWorkouts;
      _loading = false;
    });
  }

  void _fetchExercises(int workoutId) async {
    if (workoutExercises.containsKey(workoutId)) return;

    final fetchedExercises = await _workoutService.fetchExercises(workoutId);
    setState(() {
      workoutExercises[workoutId] = fetchedExercises;
    });
  }

  void _fetchWorkoutSummary(int workoutId) async {
    final fetchedSummary = await _workoutService.fetchWorkoutSummary(workoutId);
    if (fetchedSummary != null) {
      setState(() {
        workoutSummaries[workoutId] = fetchedSummary;
      });
    }
  }

  void _showWorkoutSummary(int workoutId) async {
    final summary = workoutSummaries[workoutId] ?? await _workoutService.fetchWorkoutSummary(workoutId);

    if (mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Workout Summary",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                summary != null
                    ? Column(
                        children: [
                          Text("💪 Total Sets: ${summary['totalSets']}", style: GoogleFonts.poppins(fontSize: 16)),
                          Text("🔄 Total Reps: ${summary['totalReps']}", style: GoogleFonts.poppins(fontSize: 16)),
                          Text("🏋️‍♂️ Total Weight Lifted: ${summary['totalWeightLifted']} kg", style: GoogleFonts.poppins(fontSize: 16)),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ],
            ),
          );
        },
      );
    }
  }

  // 🔹 Delete a Workout
  void _deleteWorkout(int workoutId) async {
    bool success = await _workoutService.deleteWorkout(workoutId);
    if (success) {
      setState(() {
        workouts.removeWhere((workout) => workout['id'] == workoutId);
      });
      _showSnackBar("Workout deleted successfully!", Colors.red);
    } else {
      _showSnackBar("Failed to delete workout.", Colors.red);
    }
  }

  // 🔹 Delete an Exercise
  void _deleteExercise(int workoutId, int exerciseId) async {
    bool success = await _workoutService.deleteExercise(exerciseId);
    if (success) {
      setState(() {
        workoutExercises[workoutId]?.removeWhere((exercise) => exercise['id'] == exerciseId);
      });
      _showSnackBar("Exercise deleted successfully!", Colors.red);
    } else {
      _showSnackBar("Failed to delete exercise.", Colors.red);
    }
  }

  // 🔹 Show SnackBar for Success/Error
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
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "All Workouts",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : workouts.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    final workoutId = workout['id'];
                    final exercises = workoutExercises[workoutId] ?? [];

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ExpansionTile(
                        title: Text(
                          "${workout['notes'] ?? 'Workout'} - ${workout['createdAt'] ?? 'Unknown Date'}",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteWorkout(workoutId),
                            ),
                          ],
                        ),
                        children: [
                          exercises.isNotEmpty
                              ? Column(
                                  children: exercises.map((exercise) {
                                    return ListTile(
                                      leading: const Icon(Icons.fitness_center, color: Colors.blue),
                                      title: Text(
                                        exercise['exerciseName'] ?? 'Unnamed Exercise',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text("${exercise['sets']} Sets - ${exercise['reps']} Reps - ${exercise['weight']} kg"),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteExercise(workoutId, exercise['id']),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(child: CircularProgressIndicator()),
                                ),

                          const SizedBox(height: 10),

                          // 🔹 View Summary Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                            child: ElevatedButton(
                              onPressed: () => _showWorkoutSummary(workoutId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                "View Summary",
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Center(child: Text("No workouts found.", style: GoogleFonts.poppins(fontSize: 16))),
    );
  }
}
