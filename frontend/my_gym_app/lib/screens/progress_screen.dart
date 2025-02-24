import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/progress_analytics_service.dart';
import '../services/auth_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressAnalyticsService _progressService = ProgressAnalyticsService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> progressData = [];
  List<String> userExercises = []; // 🔹 Store unique exercises
  String bestLift = "N/A";
  bool _loading = true;
  String? selectedExercise; // 🔹 Default to null, selected dynamically

  @override
  void initState() {
    super.initState();
    _fetchUserExercises();
  }

  // 🔹 Fetch all unique exercises the user has performed
  void _fetchUserExercises() async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo['id'] == null) return;

    final exercises = await _progressService.fetchUserExercises(userInfo['id']!);
    
    if (exercises != null && exercises.isNotEmpty) {
      setState(() {
        userExercises = exercises;
        selectedExercise = userExercises.first; // ✅ Default to first exercise
      });
      _fetchExerciseProgress(); // Fetch progress for the first exercise
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  // 🔹 Fetch Progress Data for selected exercise
  void _fetchExerciseProgress() async {
    if (selectedExercise == null) return;

    final userInfo = await _authService.getUserInfo();
    if (userInfo['id'] == null) return;

    final progress =
        await _progressService.fetchExerciseProgress(userInfo['id']!, selectedExercise!);

    if (progress != null && progress.isNotEmpty) {
      progress.sort((a, b) =>
          DateTime.parse(a['createdAt']).compareTo(DateTime.parse(b['createdAt'])));

      double maxWeight = progress.map((e) => e['weight'] as double).reduce((a, b) => a > b ? a : b);

      setState(() {
        progressData = progress;
        bestLift = "$maxWeight kg";
        _loading = false;
      });
    } else {
      setState(() {
        progressData = [];
        bestLift = "N/A";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "📈 Progress Tracker",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Exercise Selection Dropdown
                  Text(
                    "📌 Select an Exercise",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedExercise,
                    items: userExercises.map((exercise) {
                      return DropdownMenuItem<String>(
                        value: exercise,
                        child: Text(exercise, style: GoogleFonts.poppins(fontSize: 16)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedExercise = value;
                        _loading = true; // Show loading indicator while fetching
                      });
                      _fetchExerciseProgress(); // Fetch new exercise data
                    },
                  ),
                  const SizedBox(height: 10),

                  Text(
                    "🏆 Best Lift: $bestLift",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Line Chart for Progress Visualization
                  if (progressData.isNotEmpty) _buildProgressChart(),

                  const SizedBox(height: 20),

                  // 🔹 Exercise Progress List
                  Text(
                    "📜 Exercise History",
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  progressData.isNotEmpty
                      ? Column(
                          children: progressData.map((data) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              child: ListTile(
                                title: Text(
                                  "${data['exerciseName']}",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    "📅 ${DateFormat('yyyy-MM-dd').format(DateTime.parse(data['createdAt']))} | 🔄 ${data['reps']} Reps | 🏋️‍♂️ ${data['weight']} kg"),
                              ),
                            );
                          }).toList(),
                        )
                      : Text("No progress data found.",
                          style: GoogleFonts.poppins(fontSize: 16)),
                ],
              ),
            ),
    );
  }

  /// 🔹 Builds a Line Chart to show progress trends
  Widget _buildProgressChart() {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        "${value.toInt()} kg",
                        style: GoogleFonts.poppins(fontSize: 12),
                      );
                    })),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < progressData.length) {
                        return Text(
                          DateFormat('MM/dd').format(
                              DateTime.parse(progressData[index]['createdAt'])),
                          style: GoogleFonts.poppins(fontSize: 10),
                        );
                      }
                      return const SizedBox.shrink();
                    }))),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: progressData.asMap().entries.map((entry) {
                int index = entry.key;
                double weight = entry.value['weight'] as double;
                return FlSpot(index.toDouble(), weight);
              }).toList(),
              isCurved: true,
              color: Colors.blueAccent,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
