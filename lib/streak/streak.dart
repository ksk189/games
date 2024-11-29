import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:games/firebase/user/streak_repository.dart';

class StreakPage extends StatefulWidget {
  final String userId;

  const StreakPage({super.key, required this.userId});

  @override
  _StreakPageState createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  late final StreakRepository streakRepository;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final Map<DateTime, bool> _streaks = {};

  @override
  void initState() {
    super.initState();
    // Initialize StreakRepository with the provided userId
    streakRepository = StreakRepository(userId: widget.userId);
    _loadStreaks();
    _checkAndPromptStreak();
  }

  // Load streaks from Firestore
  Future<void> _loadStreaks() async {
    final streaks = await streakRepository.fetchStreaks();
    setState(() {
      for (var streak in streaks) {
        _streaks[DateTime(streak.date.year, streak.date.month, streak.date.day)] = streak.isMarked;
      }
    });
  }

  void _checkAndPromptStreak() async {
    final today = DateTime.now();
    bool alreadyMarked = await streakRepository.isStreakAddedForDay(today);
    if (!alreadyMarked) {
      Future.delayed(Duration.zero, () => _showAddStreakDialog(context));
    }
  }

  void _addStreak(DateTime day) async {
    await streakRepository.addOrUpdateStreak(day);
    setState(() {
      _streaks[DateTime(day.year, day.month, day.day)] = true;
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Streak added for today!')),
    );
  }

  void _showAddStreakDialog(BuildContext context) {
    final today = DateTime.now();
    if (_streaks.containsKey(DateTime(today.year, today.month, today.day))) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Streak Already Marked'),
          content: const Text('You have already marked your streak for today.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Today\'s Streak'),
          content: const Text(
            'Click "Add Streak" to mark today as a streak.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _addStreak(today),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
              child: const Text('Add Streak'),
            ),
          ],
        ),
      );
    }
  }

  bool _isStreak(DateTime day) {
    return _streaks[DateTime(day.year, day.month, day.day)] ?? false;
  }

  List<DateTime> _getCurrentWeekDays(DateTime date) {
    int dayOfWeek = date.weekday;
    DateTime startOfWeek = date.subtract(Duration(days: dayOfWeek - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> currentWeekDays = _getCurrentWeekDays(_focusedDay);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('Streak Tracker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Navigate back
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_streaks.length}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Week Streak',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: currentWeekDays.map((day) {
                      bool isMarked = _isStreak(day);
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isMarked ? Colors.orangeAccent : Colors.grey.shade300,
                            child: isMarked
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            DateFormat('E').format(day),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1.0,
              color: Colors.grey,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10.0,
                        spreadRadius: 5.0,
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: _isStreak(day) ? Colors.orangeAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: _isStreak(day) ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}