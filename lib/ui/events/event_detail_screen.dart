import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import '../../models/event.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final String eventType;

  EventDetailScreen({required this.event, required this.eventType});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: primaryPink,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryPink, rosePink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        _getEventIcon(widget.event.type),
                        size: 80,
                        color: white,
                      ),
                    ),
                    if (widget.eventType == 'live')
                      Positioned(
                        top: 100,
                        right: 30,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: errorRed,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: softPink,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventHeader(),
                    SizedBox(height: 25),
                    _buildEventInfo(),
                    SizedBox(height: 25),
                    _buildDescription(),
                    SizedBox(height: 25),
                    _buildHost(),
                    SizedBox(height: 25),
                    _buildAttendees(),
                    SizedBox(height: 25),
                    if (widget.eventType == 'upcoming') _buildAgenda(),
                    if (widget.eventType == 'upcoming') SizedBox(height: 30),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                widget.event.type,
                style: TextStyle(
                  fontSize: 12,
                  color: primaryPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Spacer(),
            if (widget.event.isRSVPed)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: successGreen),
                    SizedBox(width: 4),
                    Text(
                      'RSVP\'d',
                      style: TextStyle(
                        fontSize: 12,
                        color: successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 15),
        Text(
          widget.event.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkGrey,
          ),
        ),
        SizedBox(height: 10),
        Text(
          widget.event.description,
          style: TextStyle(
            fontSize: 16,
            color: mediumGrey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: lightPink.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.access_time, 'Date & Time', _formatDateTime()),
          SizedBox(height: 15),
          _buildInfoRow(Icons.location_on, 'Location', widget.event.location),
          SizedBox(height: 15),
          _buildInfoRow(Icons.people, 'Attendees', '${widget.event.attendees} ${widget.eventType == 'live' ? 'watching' : 'registered'}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primaryPink.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryPink, size: 20),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: mediumGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About This Event',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkGrey,
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            'Join us for an incredible learning experience that will transform your creative journey. This ${widget.event.type.toLowerCase()} is designed to provide hands-on experience, expert insights, and networking opportunities with fellow creatives. Whether you\'re a beginner or looking to advance your skills, this event offers valuable content tailored to help you grow in your artistic pursuits.',
            style: TextStyle(
              fontSize: 14,
              color: darkGrey,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHost() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Host',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkGrey,
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: primaryPink,
                child: Icon(Icons.person, color: white, size: 30),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.host,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Expert ${widget.event.type} Facilitator',
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Experienced professional with 10+ years in the creative industry',
                      style: TextStyle(
                        fontSize: 12,
                        color: mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                child: Text('View Profile', style: TextStyle(color: primaryPink, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryPink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendees() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attendees (${widget.event.attendees})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGrey,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('View All', style: TextStyle(color: primaryPink)),
            ),
          ],
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Container(
                    margin: EdgeInsets.only(right: 10),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryPink,
                      child: Icon(Icons.person, color: white, size: 20),
                    ),
                  );
                }),
              ),
              SizedBox(height: 15),
              Text(
                'Sarah M., Amina K., Grace O., and ${widget.event.attendees - 3} others are attending',
                style: TextStyle(
                  fontSize: 14,
                  color: mediumGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgenda() {
    final agendaItems = [
      'Welcome & Introductions (15 min)',
      'Main Presentation (45 min)',
      'Interactive Workshop (30 min)',
      'Q&A Session (20 min)',
      'Networking & Wrap-up (10 min)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Agenda',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkGrey,
          ),
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: agendaItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == agendaItems.length - 1;
              
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: isLast ? null : Border(
                    bottom: BorderSide(color: lightPink.withOpacity(0.5)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: primaryPink.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryPink,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (widget.eventType == 'live') {
      return Container(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            _joinLiveEvent();
          },
          icon: Icon(Icons.play_arrow, size: 20),
          label: Text('Join Live Session', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: errorRed,
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      );
    } else if (widget.eventType == 'upcoming') {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _addToCalendar();
                  },
                  icon: Icon(Icons.calendar_today, color: primaryPink, size: 18),
                  label: Text('Add to Calendar', style: TextStyle(color: primaryPink)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: primaryPink),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _shareEvent();
                  },
                  icon: Icon(Icons.share, color: primaryPink, size: 18),
                  label: Text('Share', style: TextStyle(color: primaryPink)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: primaryPink),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _toggleRSVP();
              },
              child: Text(
                widget.event.isRSVPed ? 'Cancel RSVP' : 'RSVP Now',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.event.isRSVPed ? warningOrange : primaryPink,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.replay, color: primaryPink),
          label: Text('View Recording', style: TextStyle(color: primaryPink)),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15),
            side: BorderSide(color: primaryPink),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      );
    }
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

  String _formatDateTime() {
    if (widget.eventType == 'live') {
      return 'Live now';
    }
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${months[widget.event.dateTime.month - 1]} ${widget.event.dateTime.day}, ${widget.event.dateTime.year} at ${widget.event.dateTime.hour}:${widget.event.dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _joinLiveEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join Live Session'),
        content: Text('You\'re about to join the live session. Make sure you have a stable internet connection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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

  void _addToCalendar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event added to calendar!'),
        backgroundColor: successGreen,
      ),
    );
  }

  void _shareEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event shared successfully!'),
        backgroundColor: primaryPink,
      ),
    );
  }

  void _toggleRSVP() {
    setState(() {
      widget.event.isRSVPed = !widget.event.isRSVPed;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.event.isRSVPed ? 'RSVP confirmed!' : 'RSVP cancelled'),
        backgroundColor: widget.event.isRSVPed ? successGreen : warningOrange,
      ),
    );
  }
}