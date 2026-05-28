import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Map<String, int> moodScores = {
    '😡 Angry': 1,
    '😢 Sad': 2,
    '🤢 Sick': 2,
    '😴 Tired': 3,
    '🧘 Calm': 4,
    '😊 Happy': 5,
  };

  Future<bool> logUserMood(String mood) async{
    try{
      final FirebaseAuth freshAuth = FirebaseAuth.instance;
      User? currentUser = freshAuth.currentUser;

      if (currentUser != null){
        int score = moodScores[mood] ?? 3;
        DateTime now = DateTime.now();
        String todayString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        String dailyDocId = "${currentUser.uid}_$todayString";
        await _db.collection('mood_logs').doc(dailyDocId).set({
          'uid': currentUser.uid,
          'mood': mood,
          'score': score,
          'timeStamp': Timestamp.now(),
        });
        return true;
      }
      return false;
    } catch(e){
      print('Error saving mood to FireStore: ${e.toString()}');
      return false;
    }
  }

  Future<List<int>> getPastSevenDaysScores() async {
    List<int> scores = [];
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null)
      {print("🛑 DEBUG: Read failed. No user logged in.");
        return scores;}

      DateTime sevenDaysAgoDateTime = DateTime.now().subtract(const Duration(days: 7));
      Timestamp sevenDaysAgoTimestamp = Timestamp.fromDate(sevenDaysAgoDateTime);

      print("=== 🔍 DEBUG START: FETCHING SCORES ===");
      print("1. Searching for UID: ${currentUser.uid}");
      print("2. Looking for dates after: ${sevenDaysAgoDateTime.toString()}");

      QuerySnapshot querySnapshot = await _db
          .collection('mood_logs')
          .where('uid', isEqualTo: currentUser.uid)
          .where('timeStamp', isGreaterThanOrEqualTo: sevenDaysAgoTimestamp)
          .get();

      print("3. Documents found in Firebase: ${querySnapshot.docs.length}");

      for (var doc in querySnapshot.docs) {
        dynamic data = doc.data();
        if (data != null && data['score'] != null) {
          scores.add(data['score'] as int);
        }
      }
      print("4. Final extracted scores array: $scores");
      print("=======================================");
    } catch (e) {
      print("🛑 DEBUG ERROR: ${e.toString()}");
      print("Error fetching historical mood data: ${e.toString()}");
    }
    return scores;
  }

  String getWeeklyRecommendation(List<int> pastSevenDaysScores) {
    if (pastSevenDaysScores.isEmpty) {
      return "Start tracking your mood daily to generate personalized mental health insights!";
    }

    double sum = pastSevenDaysScores.reduce((a, b) => a + b).toDouble();
    double average = sum / pastSevenDaysScores.length;

    if (average >= 4.5) {
      return "🚀 You're thriving! This is a great week to tackle challenging goals or dive into creative projects.";
    } else if (average >= 3.5) {
      return "✨ Doing well! Maintain your momentum with consistent sleep and active movement.";
    } else if (average >= 2.5) {
      return "⚖️ You're in a stable, neutral space. Consider journaling or listening to music to re-energize.";
    } else {
      return "🛑 Tough week. It's completely okay to feel this way. We highly recommend trying a 5-minute deep breathing session or talking to a close friend.";
    }
  }

  // Fetch full history, sorted newest to oldest
  Future<List<Map<String, dynamic>>> getFullUserHistory() async {
    List<Map<String, dynamic>> historyList = [];
    try {
      final FirebaseAuth freshAuth = FirebaseAuth.instance;
      User? currentUser = freshAuth.currentUser;
      if (currentUser == null) return historyList;

      QuerySnapshot querySnapshot = await _db
          .collection('mood_logs')
          .where('uid', isEqualTo: currentUser.uid)
          .orderBy('timeStamp', descending: true) // Sorts newest days at the top
          .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        historyList.add(data);
      }
    } catch (e) {
      print("Error fetching full history: ${e.toString()}");
    }
    return historyList;
  }

  Future<bool> deleteMoodLog(String docId) async{
    try{
      await _db.collection('mood_logs').doc(docId).delete();
      return true;
    } catch(e){
      print('Error deleting document: ${e.toString()}');
      return false;
    }
  }

}

