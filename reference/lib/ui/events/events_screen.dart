import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursehub/utils/index.dart';
import '../../widgets/loading_overlay.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import 'event_detail_screen.dart';
import '../../widgets/beauty_calendar.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Event> _convertToEventList(List<Map<String, dynamic>> eventsData, String filter) {
    final now = DateTime.now();
    return eventsData.map((data) {
      final dateTime = data['dateTime'] is Timestamp
          ? (data['dateTime'] as Timestamp).toDate()
          : DateTime.parse(data['dateTime'] ?? DateTime.now().toIso8601String());
      
      // Filter events based on type
      if (filter == 'upcoming' && dateTime.isBefore(now)) return null;
      if (filter == 'live' && (dateTime.isAfter(now) || dateTime.isBefore(now.subtract(Duration(hours: 2))))) return null;
      if (filter == 'past' && dateTime.isAfter(now)) return null;

      final attendees = data['attendees'] as List<dynamic>? ?? [];
      return Event(
        data['title'] ?? 'Untitled Event',
        data['description'] ?? '',
        dateTime,
        data['type'] ?? 'Event',
        data['host'] ?? data['creatorName'] ?? 'Unknown',
        attendees.length,
        false, // Will be updated based on user RSVP
        data['location'] ?? 'Online',
      );
    }).whereType<Event>().toList();
  }

  final List<Event> upcomingEvents = [
    Event(
      'Color Theory Masterclass',
      'Learn advanced color techniques from professional artists',
      DateTime.now().add(Duration(days: 2)),
      'Workshop',
      'Amara Johnson',
      120,
      true,
      'Online',
    ),
    Event(
      'African Art Heritage Exhibition',
      'Celebrating traditional and contemporary African art',
      DateTime.now().add(Duration(days: 5)),
      'Exhibition',
      'Cultural Center',
      500,
      false,
      'Lagos, Nigeria',
    ),
    Event(
      'Music Production Bootcamp',
      'Intensive 3-day bootcamp for aspiring producers',
      DateTime.now().add(Duration(days: 7)),
      'Bootcamp',
      'Kemi Adebayo',
      50,
      true,
      'Online',
    ),
    Event(
      'Creative Entrepreneurship Summit',
      'Building sustainable creative businesses',
      DateTime.now().add(Duration(days: 10)),
      'Conference',
      'Multiple Speakers',
      300,
      false,
      'Accra, Ghana',
    ),
  ];

  final List<Event> liveEvents = [
    Event(
      'Digital Painting Q&A',
      'Live session with questions and answers',
      DateTime.now(),
      'Live Session',
      'Sarah Mitchell',
      89,
      true,
      'Online',
    ),
  ];

  final List<Event> pastEvents = [
    Event(
      'Photography Basics Workshop',
      'Introduction to portrait photography',
      DateTime.now().subtract(Duration(days: 3)),
      'Workshop',
      'Fatou Diallo',
      156,
      true,
      'Online',
    ),
    Event(
      'Creative Writing Circle',
      'Monthly writing workshop and feedback session',
      DateTime.now().subtract(Duration(days: 7)),
      'Workshop',
      'Aisha Mwangi',
      45,
      false,
      'Nairobi, Kenya',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        title: Text('Events', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryPink,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: white,
          labelColor: white,
          unselectedLabelColor: white.withValues(alpha: 0.7),
          tabs: [
            Tab(text: 'Calendar'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Live'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading && eventProvider.events.isEmpty) {
            return LoadingIndicator(message: 'Loading events...');
          }

          if (eventProvider.error != null && eventProvider.events.isEmpty) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Error loading events',
              message: eventProvider.error,
              action: ElevatedButton(
                onPressed: () {
                  // Events will reload automatically
                },
                child: Text('Retry'),
              ),
            );
          }

          final upcoming = _convertToEventList(eventProvider.events, 'upcoming');
          final live = _convertToEventList(eventProvider.events, 'live');
          final past = _convertToEventList(eventProvider.events, 'past');

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCalendarTab(eventProvider),
              _buildEventsList(upcoming.isEmpty ? upcomingEvents : upcoming, 'upcoming', eventProvider),
              _buildEventsList(live.isEmpty ? liveEvents : live, 'live', eventProvider),
              _buildEventsList(past.isEmpty ? pastEvents : past, 'past', eventProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventsList(List<Event> events, String type, EventProvider? eventProvider) {
    if (events.isEmpty) {
      return EmptyState(
        icon: type == 'live' ? Icons.live_tv : Icons.event,
        title: type == 'live' 
            ? 'No live events right now'
            : type == 'upcoming'
                ? 'No upcoming events'
                : 'No past events',
        message: type == 'upcoming' 
            ? 'Check back later for new events'
            : null,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _buildEventCard(events[index], type, eventProvider);
      },
    );
  }

  Widget _buildEventCard(Event event, String type, EventProvider? eventProvider) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
        border: type == 'live' ? Border.all(color: errorRed, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: lightPink.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event, eventType: type),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getEventIcon(event.type),
                      size: 40,
                      color: primaryPink,
                    ),
                  ),
                  if (type == 'live')
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: errorRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryPink.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        event.type,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: mediumGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.person, color: primaryPink, size: 16),
                      SizedBox(width: 4),
                      Text(
                        event.host,
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: mediumGrey, size: 16),
                      SizedBox(width: 4),
                      Text(
                        _formatDateTime(event.dateTime, type),
                        style: TextStyle(
                          fontSize: 12,
                          color: mediumGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: mediumGrey, size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: mediumGrey,
                          ),
                        ),
                      ),
                      Text(
                        '${event.attendees} ${type == 'live' ? 'watching' : 'attending'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (type == 'upcoming') ...[
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _addToCalendar(event);
                            },
                            child: Text('Add to Calendar', style: TextStyle(color: primaryPink)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryPink),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _rsvpEvent(event);
                            },
                            child: Text(event.isRSVPed ? 'RSVP\'d' : 'RSVP'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: event.isRSVPed ? successGreen : primaryPink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (type == 'live') ...[
                    SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _joinLiveEvent(event);
                        },
                        icon: Icon(Icons.play_arrow),
                        label: Text('Join Live Session'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: errorRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'Workshop': return Icons.school;
      case 'Exhibition': return Icons.museum;
      case 'Bootcamp': return Icons.fitness_center;
      case 'Conference': return Icons.business;
      case 'Live Session': return Icons.live_tv;
      default: return Icons.event;
    }
  }

  String _formatDateTime(DateTime dateTime, String type) {
    if (type == 'live') {
      return 'Live now';
    }
    
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;
    
    if (type == 'past') {
      return '${difference.abs()} days ago';
    }
    
    if (difference == 0) {
      return 'Today at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Tomorrow at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return 'In $difference days';
    }
  }

  void _addToCalendar(Event event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event added to calendar!'),
        backgroundColor: successGreen,
      ),
    );
  }

  void _rsvpEvent(Event event) {
    setState(() {
      event.isRSVPed = !event.isRSVPed;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(event.isRSVPed ? 'RSVP confirmed!' : 'RSVP cancelled'),
        backgroundColor: event.isRSVPed ? successGreen : warningOrange,
      ),
    );
  }

  void _joinLiveEvent(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join Live Session'),
        content: Text('You\'re about to join "${event.title}". Make sure you have a stable internet connection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to live session screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Joining live session...'),
                  backgroundColor: primaryPink,
                ),
              );
            },
            child: Text('Join Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(EventProvider eventProvider) {
    final upcoming = _convertToEventList(eventProvider.events, 'upcoming');
    final displayEvents = upcoming.isEmpty ? upcomingEvents : upcoming;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          BeautyCalendar(),
          SizedBox(height: 20),
          Text(
            'Upcoming Events This Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkGrey,
            ),
          ),
          SizedBox(height: 15),
          ...displayEvents.take(2).map((event) => 
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: _buildEventCard(event, 'upcoming', eventProvider),
            )
          ).toList(),
        ],
      ),
    );
  }
}

