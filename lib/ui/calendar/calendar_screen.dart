import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';
import '../../services/preferences_service.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEventsForDay(_selectedDay!);
  }

  void _loadEventsForDay(DateTime day) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final dayEvents = eventProvider.events.where((event) {
      try {
        final eventDateTime = event['dateTime'];
        DateTime eventDate;
        if (eventDateTime is DateTime) {
          eventDate = eventDateTime;
        } else if (eventDateTime is String) {
          eventDate = DateTime.parse(eventDateTime);
        } else {
          eventDate = DateTime.now();
        }
        return isSameDay(eventDate, day);
      } catch (e) {
        return false;
      }
    }).toList();
    
    setState(() {
      _selectedEvents = dayEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.of(context).canPop() ? Navigator.pop(context) : null,
        ),
        title: Text(
          'Calendar & Reminders',
          style: TextStyle(fontFamily: 'Lato'),
        ),
        backgroundColor: primaryPink,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddReminderDialog,
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: white,
                ),
                tooltip: 'Toggle theme',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                return TableCalendar<Map<String, dynamic>>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) {
                    return eventProvider.events.where((event) {
                      try {
                        final eventDateTime = event['dateTime'];
                        DateTime eventDate;
                        if (eventDateTime is DateTime) {
                          eventDate = eventDateTime;
                        } else if (eventDateTime is String) {
                          eventDate = DateTime.parse(eventDateTime);
                        } else {
                          return false;
                        }
                        return isSameDay(eventDate, day);
                      } catch (e) {
                        return false;
                      }
                    }).toList();
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    selectedDecoration: BoxDecoration(
                      color: primaryPink,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: primaryPink.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: rosePink,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(color: primaryPink),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: primaryPink,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _loadEventsForDay(selectedDay);
                    }
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
                );
              },
            ),
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: _selectedEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 64,
                          color: mediumGrey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No events for this day',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: mediumGrey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap + to add a reminder',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedEvents[index];
                      return _buildEventCard(event, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    DateTime eventDate;
    try {
      final eventDateTime = event['dateTime'];
      if (eventDateTime is DateTime) {
        eventDate = eventDateTime;
      } else if (eventDateTime is String) {
        eventDate = DateTime.parse(eventDateTime);
      } else {
        eventDate = DateTime.now();
      }
    } catch (e) {
      eventDate = DateTime.now();
    }
    final timeString = '${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: primaryPink.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getEventIcon(event['type'] ?? 'event'),
            color: primaryPink,
          ),
        ),
        title: Text(
          event['title'] ?? 'Untitled Event',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              timeString,
              style: theme.textTheme.bodySmall?.copyWith(
                color: primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (event['description'] != null) ...[
              SizedBox(height: 4),
              Text(
                event['description'],
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'remind',
              child: Row(
                children: [
                  Icon(Icons.notifications, size: 20),
                  SizedBox(width: 8),
                  Text('Set Reminder'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'remind') {
              _setEventReminder(event);
            }
          },
        ),
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type.toLowerCase()) {
      case 'workshop':
        return Icons.build;
      case 'webinar':
        return Icons.video_call;
      case 'course':
        return Icons.school;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.event;
    }
  }

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Date'),
                  subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text('Time'),
                  subtitle: Text('${selectedTime.format(context)}'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  await _createReminder(
                    titleController.text,
                    descriptionController.text,
                    selectedDate,
                    selectedTime,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createReminder(
    String title,
    String description,
    DateTime date,
    TimeOfDay time,
  ) async {
    final eventDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.createEvent({
      'title': title,
      'description': description,
      'dateTime': eventDateTime,
      'type': 'reminder',
      'host': 'You',
      'location': 'Personal Reminder',
    });

    final remindersEnabled = await PreferencesService.getEventReminders();
    if (remindersEnabled) {
      await NotificationService.scheduleNotification(
        id: eventDateTime.millisecondsSinceEpoch,
        title: title,
        body: description.isNotEmpty ? description : 'Reminder',
        scheduledDate: eventDateTime,
      );
    }

    _loadEventsForDay(_selectedDay!);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder added successfully!')),
    );
  }

  void _setEventReminder(Map<String, dynamic> event) async {
    final eventDate = (event['dateTime'] as DateTime?) ?? DateTime.now();
    final reminderTime = eventDate.subtract(Duration(minutes: 30));
    
    if (reminderTime.isAfter(DateTime.now())) {
      await NotificationService.scheduleNotification(
        id: eventDate.millisecondsSinceEpoch,
        title: 'Event Reminder',
        body: '${event['title']} starts in 30 minutes',
        scheduledDate: reminderTime,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder set for 30 minutes before event')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot set reminder for past events')),
      );
    }
  }
}