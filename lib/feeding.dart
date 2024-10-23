import 'dart:developer';
import 'package:flutter/material.dart';

import './main.dart';
import './database.dart';
import './calendar.dart';

class FeedingInformation extends StatefulWidget {
  final String employeeId;
  const FeedingInformation({super.key, required this.employeeId});

  @override
  FeedingInformationState createState() => FeedingInformationState();
}

class FeedingInformationState extends State<FeedingInformation> {
  final startTime = DateTime.now();
  final DatabaseService _db = DatabaseService();
  int _selectedIndex = 0;

  void _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  Future<void> _submit() async {
    try {
      _db.addFeed({
        'id': widget.employeeId,
        'time': startTime,
        'bales': getBale(_selectedIndex),
      });
      _login();
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot save data.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double getBale(int index) {
    return 1 + (index * 0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'How many hay bales?',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined), // Choose your desired icon
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyCalendar(employeeId: widget.employeeId),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: ListWheelScrollView.useDelegate(
          itemExtent: 50,
          perspective: 0.005,
          diameterRatio: 1.2,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (value) {
            setState(() {
              _selectedIndex = value; // Update the selected index
            });
          },
          childDelegate: ListWheelChildBuilderDelegate(
              childCount: 39,
              builder: (context, index) {
                return Container(
                  key: ValueKey(index),
                  child: Center(
                    child: Text(
                      getBale(index).toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 30,
                        color: (index == _selectedIndex ? Colors.red : Colors.white),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Background color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Button size
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Text size
          ),
          child: const Text('Submit'),
        ),
        ElevatedButton(
          onPressed: _login,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Button size
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Text size
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
