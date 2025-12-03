import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../models/event.dart' as AppEvent;
import '../../providers/event_provider.dart';
import 'event_detail_screen.dart';
import 'add_event_screen.dart';
import '../../widgets/beauty_calendar.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedEventType;
  String? _selectedLocation;
  
  // Cache for converted events
  List<Map<String, dynamic>>? _cachedEventsData;
  Map<String, List<AppEvent.Event>>? _cachedConvertedEvents;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _cachedConvertedEvents = null; // Invalidate cache
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<AppEvent.Event> _convertToEventList(List<Map<String, dynamic>> eventsData, String filter) {
    if (eventsData.isEmpty) return [];
    
    final now = DateTime.now();
    final List<AppEvent.Event> result = [];
    
    for (final data in eventsData) {
      try {
        DateTime dateTime;
        if (data['dateTime'] is Timestamp) {
          dateTime = (data['dateTime'] as Timestamp).toDate();
        } else if (data['dateTime'] is String) {
          dateTime = DateTime.parse(data['dateTime']);
        } else {
          continue; // Skip invalid dates
        }
        
        // Filter events based on type
        if (filter == 'upcoming' && dateTime.isBefore(now)) continue;
        if (filter == 'live' && (dateTime.isAfter(now.add(Duration(hours: 1))) || dateTime.isBefore(now.subtract(Duration(hours: 2))))) continue;
        if (filter == 'past' && dateTime.isAfter(now)) continue;

        final attendees = data['attendees'] as List<dynamic>? ?? [];
        final event = AppEvent.Event(
          data['title'] ?? 'Untitled Event',
          data['description'] ?? '',
          dateTime,
          data['type'] ?? 'Event',
          data['host'] ?? data['creatorName'] ?? 'Unknown',
          attendees.length,
          false,
          data['location'] ?? 'Online',
        );

        // Apply filters
        if (_searchQuery.isNotEmpty) {
          final searchLower = _searchQuery.toLowerCase();
          if (!event.title.toLowerCase().contains(searchLower) &&
              !event.description.toLowerCase().contains(searchLower) &&
              !event.host.toLowerCase().contains(searchLower) &&
              !event.location.toLowerCase().contains(searchLower)) {
            continue;
          }
        }

        if (_selectedEventType != null && _selectedEventType != 'All' && event.type != _selectedEventType) {
          continue;
        }

        if (_selectedLocation != null && _selectedLocation != 'All') {
          if (_selectedLocation == 'Online' && event.location.toLowerCase() != 'online') {
            continue;
          }
          if (_selectedLocation == 'In-Person' && event.location.toLowerCase() == 'online') {
            continue;
          }
        }

        result.add(event);
      } catch (e) {
        // Skip invalid events
        continue;
      }
    }
    
    return result;
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.of(context).canPop() ? Navigator.pop(context) : null,
        ),
        title: Text(
          'Events',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: primaryPink,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: white),
            onPressed: () => _showFilterDialog(),
            tooltip: 'Filter events',
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              _buildSearchBar(),
              TabBar(
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
            ],
          ),
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

          // Use cached conversion if data hasn't changed
          if (_cachedEventsData != eventProvider.events || _cachedConvertedEvents == null) {
            _cachedEventsData = eventProvider.events;
            _cachedConvertedEvents = {
              'upcoming': _convertToEventList(eventProvider.events, 'upcoming'),
              'live': _convertToEventList(eventProvider.events, 'live'),
              'past': _convertToEventList(eventProvider.events, 'past'),
            };
          }
          
          final upcoming = _cachedConvertedEvents!['upcoming']!;
          final live = _cachedConvertedEvents!['live']!;
          final past = _cachedConvertedEvents!['past']!;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCalendarTab(eventProvider),
              _buildEventsList(upcoming, 'upcoming', eventProvider),
              _buildEventsList(live, 'live', eventProvider),
              _buildEventsList(past, 'past', eventProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventScreen()),
          );
        },
        backgroundColor: primaryPink,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: primaryPink,
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: white),
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: TextStyle(color: white.withValues(alpha: 0.7)),
          prefixIcon: Icon(Icons.search, color: white),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: white),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: white.withValues(alpha: 0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Events'),
        backgroundColor: theme.cardColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Type', style: theme.textTheme.titleMedium),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['All', 'Workshop', 'Exhibition', 'Conference', 'Bootcamp', 'Live Session']
                  .map((type) => FilterChip(
                        label: Text(type),
                        selected: _selectedEventType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedEventType = selected ? type : null;
                            _cachedConvertedEvents = null;
                          });
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
            SizedBox(height: 16),
            Text('Location', style: theme.textTheme.titleMedium),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['All', 'Online', 'In-Person']
                  .map((location) => FilterChip(
                        label: Text(location),
                        selected: _selectedLocation == location,
                        onSelected: (selected) {
                          setState(() {
                            _selectedLocation = selected ? location : null;
                            _cachedConvertedEvents = null;
                          });
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedEventType = null;
                _selectedLocation = null;
                _cachedConvertedEvents = null;
              });
              Navigator.pop(context);
            },
            child: Text('Clear Filters'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<AppEvent.Event> events, String type, EventProvider? eventProvider) {
    if (events.isEmpty) {
      return EmptyState(
        icon: type == 'live' ? Icons.live_tv : Icons.event,
        title: _searchQuery.isNotEmpty || _selectedEventType != null || _selectedLocation != null
            ? 'No events match your filters'
            : type == 'live' 
                ? 'No live events right now'
                : type == 'upcoming'
                    ? 'No upcoming events'
                    : 'No past events',
        message: _searchQuery.isNotEmpty || _selectedEventType != null || _selectedLocation != null
            ? 'Try adjusting your search or filters'
            : type == 'upcoming' 
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

  Widget _buildEventCard(AppEvent.Event event, String type, EventProvider? eventProvider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: type == 'live' ? Border.all(color: errorRed, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
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
                      Icon(Icons.access_time, color: theme.iconTheme.color?.withValues(alpha: 0.6) ?? mediumGrey, size: 16),
                      SizedBox(width: 4),
                      Text(
                        _formatDateTime(event.dateTime, type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: theme.iconTheme.color?.withValues(alpha: 0.6) ?? mediumGrey, size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
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

  void _addToCalendar(AppEvent.Event event) async {
    try {
      final calendarEvent = Event(
        title: event.title,
        description: event.description,
        location: event.location,
        startDate: event.dateTime,
        endDate: event.dateTime.add(Duration(hours: 2)),
      );
      
      await Add2Calendar.addEvent2Cal(calendarEvent);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event added to calendar!'),
          backgroundColor: successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not add to calendar: $e'),
          backgroundColor: errorRed,
        ),
      );
    }
  }

  void _rsvpEvent(AppEvent.Event event) {
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

  void _joinLiveEvent(AppEvent.Event event) {
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
    final displayEvents = upcoming;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'Calendar View',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryPink,
                ),
              ),
            ),
          ),
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
          if (displayEvents.isEmpty)
            EmptyState(
              icon: Icons.event,
              title: 'No upcoming events',
              message: 'Create your first event using the + button',
            )
          else
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

