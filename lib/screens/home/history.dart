import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindspace/services/database.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Database _db = Database();

  Future<void> _confirmDelete(String docId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry?'),
          content: const Text(
              'Are you sure you want to permanently delete this mood log?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );


    if (confirm == true) {
      bool success = await _db.deleteMoodLog(docId);
      if (success) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully.')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text('My Mood History', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white), // Makes the back arrow white
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _db.getFullUserHistory(),
        builder: (context, snapshot) {
          // 1. Show loading circle while waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.brown));
          }

          // 2. Handle errors
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }


          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No mood history yet.\nStart logging today!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }


          List<Map<String, dynamic>> history = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              var log = history[index];


              Timestamp? ts = log['timeStamp'] as Timestamp?;
              String dateString = "Unknown Date";
              if (ts != null) {
                DateTime dt = ts.toDate();

                dateString = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.brown,
                    child: Icon(Icons.mood, color: Colors.white),
                  ),
                  title: Text(
                    log['mood'] ?? 'Unknown',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Score: ${log['score']}/5.0'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {

                      _confirmDelete(log['docId']);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}