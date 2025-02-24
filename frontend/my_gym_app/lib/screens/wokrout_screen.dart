import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gym_app/services/auth_service.dart';
import '../services/workout_service.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  @override
  _WorkoutsScreenState createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final WorkoutService _workoutService = WorkoutService();
  final AuthService _authService = AuthService();

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
    print("Fetching workouts..."); // Debugging line
    final fetchedWorkouts = await _workoutService.fetchWorkouts();

    setState(() {
      workouts = fetchedWorkouts;
      _loading = false;
    });

    for (var workout in fetchedWorkouts) {
      int workoutId = workout['id'];
      _fetchExercises(workoutId); // Fetch exercises after updating state
    }
  }

  void _fetchExercises(int workoutId) async {
    if (workoutExercises.containsKey(workoutId)) return;

    final fetchedExercises = await _workoutService.fetchExercises(workoutId);
    setState(() {
      workoutExercises[workoutId] =
          fetchedExercises.isEmpty ? [] : fetchedExercises;
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
    final summary = workoutSummaries[workoutId] ??
        await _workoutService.fetchWorkoutSummary(workoutId);

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
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                summary != null
                    ? Column(
                        children: [
                          Text("💪 Total Sets: ${summary['totalSets']}",
                              style: GoogleFonts.poppins(fontSize: 16)),
                          Text("🔄 Total Reps: ${summary['totalReps']}",
                              style: GoogleFonts.poppins(fontSize: 16)),
                          Text(
                              "🏋️‍♂️ Total Weight Lifted: ${summary['totalWeightLifted']} kg",
                              style: GoogleFonts.poppins(fontSize: 16)),
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
        workoutExercises[workoutId]
            ?.removeWhere((exercise) => exercise['id'] == exerciseId);
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _workoutService.fetchWorkouts(), // Fetch workouts dynamically
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final workouts = snapshot.data!;
          if (workouts.isEmpty) {
            return Center(
              child: Text("No workouts found.",
                  style: GoogleFonts.poppins(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              final workoutId = workout['id'];

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _workoutService.fetchExercises(workoutId),
                builder: (context, exerciseSnapshot) {
                  final exercises = exerciseSnapshot.data ?? [];

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ExpansionTile(
                      title: Text(
                        "${workout['notes'] ?? 'Workout'} - ${workout['createdAt'] ?? 'Unknown Date'}",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteWorkout(workoutId),
                      ),
                      children: [
                        // 🔹 Show exercises if available
                        exercises.isNotEmpty
                            ? Column(
                                children: exercises.map((exercise) {
                                  return ListTile(
                                    leading: const Icon(Icons.fitness_center,
                                        color: Colors.blue),
                                    title: Text(
                                      exercise['exerciseName'] ??
                                          'Unnamed Exercise',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        "${exercise['sets']} Sets - ${exercise['reps']} Reps - ${exercise['weight']} kg"),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteExercise(
                                          workoutId, exercise['id']),
                                    ),
                                  );
                                }).toList(),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  "No exercises added yet.",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),

                        const SizedBox(height: 5),

                        // 🔹 Always show "Add Exercise" button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 5),
                          child: ElevatedButton(
                            onPressed: () => _showAddExerciseModal(workoutId),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: Text(
                              "Add Exercise",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 🔹 View Summary Button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 5),
                          child: ElevatedButton(
                            onPressed: () => _showWorkoutSummary(workoutId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              "View Summary",
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
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

      // ✅ Fetch workouts after adding a new one
      _fetchWorkouts();

      // ✅ Open the Add Exercise modal for the newly created workout
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

  Future<void> _addExerciseToWorkout(int workoutId, String exerciseName,
      int sets, int reps, double weight) async {
    final exercise = {
      "workoutId": workoutId,
      "exerciseName": exerciseName,
      "sets": sets,
      "reps": reps,
      "weight": weight
    };

    bool success = await _workoutService.addExercise(exercise);

    if (success) {
      _showSnackBar("Exercise Added! 💪", Colors.green);

      _fetchExercises(workoutId); // ✅ Refresh exercises immediately
      _fetchWorkouts(); // ✅ Ensure workout list is up-to-date
    } else {
      _showSnackBar("Failed to add exercise", Colors.red);
    }
  }
}
