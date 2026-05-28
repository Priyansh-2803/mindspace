import 'package:flutter/material.dart';
import 'package:mindspace/services/auth.dart';
import 'package:mindspace/services/database.dart';
import 'package:mindspace/screens/home/history.dart';

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();

  final Database _db = Database();

  String? _selectedEmoji;
  List<int> _weeklyScores = [];
  String _currentRecommendation = "Select a mood below to begin generating insights!";
  bool _isLoadingScores = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyInsights(); // Fetch historical records immediately when screen opens
  }
  Future<void> _loadWeeklyInsights() async {
    setState(() => _isLoadingScores = true);

    List<int> scores = await _db.getPastSevenDaysScores();
    String recommendation = _db.getWeeklyRecommendation(scores);

    setState(() {
      _weeklyScores = scores;
      _currentRecommendation = recommendation;
      _isLoadingScores = false;
    });
  }
  double get _weeklyAverage {
    if (_weeklyScores.isEmpty) return 0.0;
    return _weeklyScores.reduce((a, b) => a + b) / _weeklyScores.length;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text(
          'Home Screen',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,

        actions: <Widget>[
          IconButton(onPressed: () async{
            await _auth.signOut();
          }, icon: Icon(Icons.exit_to_app, color: Colors.white),)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
            value: _selectedEmoji,
            hint: const Text('Select your current mood'),
            decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.brown, width: 2), // Matching theme
            ),
            ),
            // Reading key array options straight out of service dictionary mapping file!
            items: _db.moodScores.keys.map((String emoji) {
            return DropdownMenuItem<String>(
            value: emoji,
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
            );
            }).toList(),
            onChanged: (String? newValue) async {
            if (newValue != null) {
            setState(() {
            _selectedEmoji = newValue;
            });
            bool success = await _db.logUserMood(newValue);

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mood logged securely in the cloud!')),
              );
              // Refresh data tracking loops instantly upon entry submissions
              await _loadWeeklyInsights();
            }
            }
            },
            ),

        const SizedBox(height: 30),

            _isLoadingScores
                ? const Center(child: CircularProgressIndicator(color: Colors.brown))
                : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "7-Day Mind Insights",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.brown.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Avg: ${_weeklyAverage.toStringAsFixed(1)}/5.0",
                          style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    _currentRecommendation,
                    style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 30),

                  // The New History Button
                  SizedBox(
                    width: double.infinity, // Makes the button stretch full width
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HistoryScreen()),
                        );

                        // 3. This line runs the exact millisecond the user closes the History screen!
                        _loadWeeklyInsights();
                      },
                      icon: const Icon(Icons.history, color: Colors.white),
                      label: const Text(
                        'View Full History',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


