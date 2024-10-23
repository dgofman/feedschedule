import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import './database.dart';
import './feeding.dart';

const maxWeeks = 3;
final kLastDay = DateTime.now().add(const Duration(days: maxWeeks * 7));

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: (DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  },
);

class MyCalendar extends StatefulWidget {
  final String employeeId;
  const MyCalendar({super.key, required this.employeeId});

  @override
  State<MyCalendar> createState() => _CalendarState();
}

class _CalendarState extends State<MyCalendar> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  final DatabaseService _db = DatabaseService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  Future<void> _submit() async {
    if (_rangeStart != null) {
      DateTime startDate = _rangeStart!;
      DateTime endDate = _rangeEnd ?? _rangeStart!;
      for (DateTime t = startDate; t.isBefore(endDate) || t.isAtSameMomentAs(endDate); t = t.add(const Duration(days: 1))) {
        List<Event> events = _getEventsForDay(t);
        if (events.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The day ${t.day} is already taken by someone.'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      _db.addEvent({
        'id': widget.employeeId,
        'type': 'PTO',
        'start': startDate,
        'end': endDate
      });
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FeedingInformation(employeeId: widget.employeeId),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay));
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    kEvents.clear();
    kEvents.addAll(await _db.getEvents());
    setState(() {
      kEvents;
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PTO Time'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: kLastDay,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,
        calendarFormat: _calendarFormat,
        rangeSelectionMode: _rangeSelectionMode,
        eventLoader: _getEventsForDay,
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _rangeStart = null; // Important to clean those
              _rangeEnd = null;
              _rangeSelectionMode = RangeSelectionMode.toggledOff;
            });
          }
        },
        onRangeSelected: (start, end, focusedDay) {
          setState(() {
            _selectedDay = null;
            _focusedDay = focusedDay;
            _rangeStart = start;
            _rangeEnd = end;
            _rangeSelectionMode = RangeSelectionMode.toggledOn;
          });
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
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
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FeedingInformation(employeeId: widget.employeeId),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black12,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Button size
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Text size
          ),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}