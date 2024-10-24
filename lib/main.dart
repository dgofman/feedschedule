import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

//import './firebase_options.dart';
import './database.dart';
import './feeding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FeedSchedule());
}

class FeedSchedule extends StatelessWidget {
  const FeedSchedule({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feed Schedule',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _empId = TextEditingController();
  final DatabaseService _db = DatabaseService();
  final List<dynamic> _userIds = [];

  dynamic _lastFeedRecord;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Load user IDs when the app starts
  }

  Future<void> _loadUsers() async {
    await _db.schedule();
    _userIds.addAll(await _db.fetchUsers());
    _updateFeedTime();
    _startHourlyCheck();
  }

  Future<void> _updateFeedTime() async {
    _lastFeedRecord = await _db.getLastFeed();
    setState(() {
      _lastFeedRecord;
    });
    DateTime now = DateTime.now();
    DateTime? feedTime = _lastFeedRecord?["time"].toDate();
    if (feedTime != null) {
      String? delayTime;
      if (now.hour == Schedule.morningFeedHour && (Schedule.morningFeedHour - feedTime.hour).abs()  >= Schedule.feedDelay) {
        delayTime = '${Schedule.morningFeedHour} AM';
      }
      if (now.hour == Schedule.eveningFeedHour && (Schedule.eveningFeedHour - feedTime.hour).abs() >= Schedule.feedDelay) {
        delayTime = '${Schedule.eveningFeedHour - 12} PM';
      }
      if (delayTime != null) {
        print(delayTime);
      }
    }
  }

  void _startHourlyCheck() async {
    _timer = Timer.periodic(const Duration(minutes: 30), (Timer timer) async { // Every 30 minutes
      _updateFeedTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submit() {
    String id = _empId.text.trim();
    String error = '';
    if (id.isEmpty) {
      error = 'Please enter an Employee ID.';
    } else if (!_userIds.contains(id)) {
      error = 'Invalid Employee ID.';
    }
    if (error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FeedingInformation(employeeId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime? feedTime = _lastFeedRecord?["time"].toDate();
    String formattedTime = feedTime != null
        ? '${feedTime.hour.toString().padLeft(2, '0')}:${feedTime.minute.toString().padLeft(2, '0')}'
        : '';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Feed Schedule'),
        actions: [
          Text('Last Time: $formattedTime  ', style: const TextStyle(fontSize: 20)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Center(
          child: TextField(
            controller: _empId,
            keyboardType: TextInputType.number, // Display numeric keyboard
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter Employee ID:',
              labelStyle: TextStyle(fontSize: 20),
            ),
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0), // Adjust the padding as needed
        child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Background color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Button size
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Text size
          ),
          child: const Text('Login'),
        ),
      ),
    );
  }
}