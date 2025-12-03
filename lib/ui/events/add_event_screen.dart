import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursehub/utils/index.dart';
import '../../providers/event_provider.dart';
import '../../widgets/loading_overlay.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _hostController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = 'Workshop';
  bool _setReminder = false;
  bool _isLoading = false;

  final List<String> _eventTypes = [
    'Workshop',
    'Exhibition', 
    'Conference',
    'Bootcamp',
    'Live Session',
    'Meetup',
    'Webinar'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Add Event'),
        backgroundColor: primaryPink,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Event Title',
                  icon: Icons.title,
                  validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
                ),
                SizedBox(height: 20),
                _buildDropdown(),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _hostController,
                  label: 'Host/Organizer',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty == true ? 'Host is required' : null,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  icon: Icons.location_on,
                  validator: (value) => value?.isEmpty == true ? 'Location is required' : null,
                ),
                SizedBox(height: 20),
                _buildDateTimePickers(),
                SizedBox(height: 20),
                _buildReminderSwitch(),
                SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryPink),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryPink, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    final theme = Theme.of(context);
    
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Event Type',
        prefixIcon: Icon(Icons.category, color: primaryPink),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryPink, width: 2),
        ),
      ),
      items: _eventTypes.map((type) => DropdownMenuItem(
        value: type,
        child: Text(type),
      )).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
        });
      },
    );
  }

  Widget _buildDateTimePickers() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: primaryPink),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date', style: TextStyle(fontSize: 12, color: theme.hintColor)),
                          Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: primaryPink),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Time', style: TextStyle(fontSize: 12, color: theme.hintColor)),
                          Text(_selectedTime.format(context)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderSwitch() {
    return Row(
      children: [
        Icon(Icons.notifications, color: primaryPink),
        SizedBox(width: 12),
        Expanded(
          child: Text('Set reminder notification'),
        ),
        Switch(
          value: _setReminder,
          onChanged: (value) {
            setState(() {
              _setReminder = value;
            });
          },
          activeColor: primaryPink,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitEvent,
        child: Text('Create Event'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType,
        'host': _hostController.text.trim(),
        'location': _locationController.text.trim(),
        'dateTime': Timestamp.fromDate(eventDateTime),
        'attendees': [],
      };

      await Provider.of<EventProvider>(context, listen: false).createEvent(eventData);

      if (_setReminder) {
        await _scheduleNotification(eventData, eventDateTime);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event created successfully!'),
          backgroundColor: successGreen,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating event: $e'),
          backgroundColor: errorRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scheduleNotification(Map<String, dynamic> eventData, DateTime eventDateTime) async {
    final status = await Permission.notification.request();
    if (!status.isGranted) return;

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    const androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Notifications for upcoming events',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);

    // Schedule notification 1 hour before event
    final reminderTime = eventDateTime.subtract(Duration(hours: 1));
    
    if (reminderTime.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        eventData['title'].hashCode,
        'Event Reminder',
        '${eventData['title']} starts in 1 hour',
        tz.TZDateTime.from(reminderTime, tz.local),
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
}

