import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

// https://console.firebase.google.com/

class Event {
  final String id;
  const Event(this.id);
  @override
  String toString() => id;
}

class Schedule {
  static int morningFeedHour = 0;
  static int eveningFeedHour = 0;
  static int feedDelay = 0;
}

class DatabaseService {
  final _db = FirebaseFirestore.instance;

  Future<List<dynamic>> fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('users').get();
      return querySnapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>)['id']).toList();
    } catch(e) {
      log(e.toString());
      return [];
    }
  }

  int morningFeedHour = 0;
  int eveningFeedHour = 0;
  int feedDelay = 0;

  Future<void> schedule() async {
    QuerySnapshot querySnapshot = await _db.collection('schedule').get();
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      switch(data['name']) {
        case 'morning':
          Schedule.morningFeedHour = data['time'];
          break;
        case 'evening':
          Schedule.eveningFeedHour = data['time'];
          break;
        case 'delay':
          Schedule.feedDelay = data['time'];
          break;
      }
    }
    if (Schedule.morningFeedHour == 0 || Schedule.eveningFeedHour == 0 || Schedule.feedDelay == 0) {
      _db.collection('schedule').add({'name': 'morning', 'time': Schedule.morningFeedHour = 8});
      _db.collection('schedule').add({'name': 'evening', 'time': Schedule.eveningFeedHour = 18});
      _db.collection('schedule').add({'name': 'delay', 'time': Schedule.feedDelay = 4});
    }
  }

  Future<void> addFeed(dynamic data) async {
    _db.collection('feeding').add(data);
  }

  Future<dynamic> getLastFeed() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('feeding')
        .orderBy('time', descending: true) // Order by the field
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first; // Return the last record
    } else {
      return null; // No records found
    }
  }

  Future<void> addEvent(dynamic data) async {
    _db.collection('events').add(data);
  }

  Future<Map<DateTime, List<Event>>> getEvents() async {
    try {
      DateTime utcNow = DateTime.now();
      DateTime utcNowZero = DateTime.utc(utcNow.year, utcNow.month, utcNow.day);
      QuerySnapshot querySnapshot = await _db.collection('events')
          .where('end', isGreaterThanOrEqualTo: utcNowZero)
          .get();
      Map<DateTime, List<Event>> events = {};
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime startDate = data['start'].toDate().toUtc();
        DateTime endDate = data['end'].toDate().toUtc();
        for (DateTime t = startDate; t.isBefore(endDate) || t.isAtSameMomentAs(endDate); t = t.add(const Duration(days: 1))) {
          if (!events.containsKey(t)) {
            events[t] = [];
          }
          events[t]!.add(Event(data['id']));
        }
      }
      return events;
    } catch(e) {
      log(e.toString());
      return {};
    }
  }
}