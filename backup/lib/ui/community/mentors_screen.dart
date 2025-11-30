import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';

class MentorsScreen extends StatefulWidget {
  @override
  _MentorsScreenState createState() => _MentorsScreenState();
}

class _MentorsScreenState extends State<MentorsScreen> {
  String selectedSpecialty = 'All';

  final List<String> specialties = [
    'All', 'Painting', 'Music', 'Photography', 'Design', 'Writing', 'Business'
  ];

  final List<Mentor> mentors = [
    Mentor(
      'Amara Johnson',
      'Professional Digital Artist',
      'Painting',
      4.9,
      150,
      'Lagos, Nigeria',
      '10+ years experience in digital art and illustration. Specialized in character design and concept art.',
      true,
    ),
    Mentor(
      'Kemi Adebayo',
      'Music Producer & Composer',
      'Music',
      4.8,
      89,
      'Accra, Ghana',
      'Award-winning producer with expertise in Afrobeats and contemporary music production.',
      false,
    ),
    Mentor(
      'Fatou Diallo',
      'Fashion Photographer',
      'Photography',
      4.9,
      67,
      'Dakar, Senegal',
      'International fashion photographer featured in Vogue Africa. Specializes in portrait and fashion photography.',
      true,
    ),
    Mentor(
      'Zara Okafor',
      'UI/UX Design Lead',
      'Design',
      4.7,
      134,
      'Cape Town, South Africa',
      'Lead designer at top tech company. Expert in user experience design and design systems.',
      false,
    ),
    Mentor(
      'Aisha Mwangi',
      'Creative Writer & Author',
      'Writing',
      4.8,
      78,
      'Nairobi, Kenya',
      'Published author of 3 novels. Specializes in creative writing, storytelling, and publishing.',
      true,
    ),
    Mentor(
      'Nomsa Dlamini',
      'Creative Entrepreneur',
      'Business',
      4.6,
      92,
      'Johannesburg, South Africa',
      'Founder of successful creative agency. Expert in business development and creative entrepreneurship.',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSpecialtyFilter(),
        Expanded(child: _buildMentorsList()),
      ],
    );
  }

  Widget _buildSpecialtyFilter() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          final specialty = specialties[index];
          final isSelected = selectedSpecialty == specialty;
          
          return Container(
            margin: EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedSpecialty = specialty;
                });
              },
              backgroundColor: white,
              selectedColor: primaryPink,
              labelStyle: TextStyle(
                color: isSelected ? white : darkGrey,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMentorsList() {
    final filteredMentors = mentors.where((mentor) {
      return selectedSpecialty == 'All' || mentor.specialty == selectedSpecialty;
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: filteredMentors.length,
      itemBuilder: (context, index) {
        return _buildMentorCard(filteredMentors[index]);
      },
    );
  }

  Widget _buildMentorCard(Mentor mentor) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: primaryPink,
                    child: Icon(Icons.person, color: white, size: 30),
                  ),
                  if (mentor.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: successGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      mentor.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: mediumGrey),
                        SizedBox(width: 4),
                        Text(
                          mentor.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  mentor.specialty,
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            mentor.bio,
            style: TextStyle(
              fontSize: 14,
              color: mediumGrey,
              height: 1.4,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text(
                mentor.rating.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkGrey,
                ),
              ),
              SizedBox(width: 15),
              Icon(Icons.people, color: mediumGrey, size: 16),
              SizedBox(width: 4),
              Text(
                '${mentor.mentees} mentees',
                style: TextStyle(
                  fontSize: 14,
                  color: mediumGrey,
                ),
              ),
              Spacer(),
              if (mentor.isOnline)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showMentorProfile(mentor);
                  },
                  icon: Icon(Icons.person, color: primaryPink, size: 18),
                  label: Text('View Profile', style: TextStyle(color: primaryPink)),
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    _connectWithMentor(mentor);
                  },
                  icon: Icon(Icons.message, size: 18),
                  label: Text('Connect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMentorProfile(Mentor mentor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: primaryPink,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: white,
                    child: Icon(Icons.person, color: primaryPink, size: 30),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mentor.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                        Text(
                          mentor.title,
                          style: TextStyle(
                            fontSize: 14,
                            color: white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      mentor.bio,
                      style: TextStyle(
                        fontSize: 14,
                        color: mediumGrey,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Expertise',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSkillChip('Advanced Techniques'),
                        _buildSkillChip('Portfolio Development'),
                        _buildSkillChip('Career Guidance'),
                        _buildSkillChip('Industry Insights'),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildReviewItem('Amazing mentor! Really helped me improve my skills.', 'Sarah M.', 5),
                    _buildReviewItem('Professional and knowledgeable. Highly recommend!', 'Amina K.', 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        skill,
        style: TextStyle(
          fontSize: 12,
          color: primaryPink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReviewItem(String review, String reviewer, int rating) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                reviewer,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
              Spacer(),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 14,
                    color: index < rating ? Colors.amber : lightGrey,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            review,
            style: TextStyle(
              fontSize: 14,
              color: mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  void _connectWithMentor(Mentor mentor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect with ${mentor.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send a message to introduce yourself and explain what you\'d like to learn.'),
            SizedBox(height: 15),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Hi ${mentor.name.split(' ')[0]}, I\'m interested in...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
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
                  content: Text('Connection request sent to ${mentor.name}!'),
                  backgroundColor: successGreen,
                ),
              );
            },
            child: Text('Send Request'),
          ),
        ],
      ),
    );
  }
}

class Mentor {
  final String name;
  final String title;
  final String specialty;
  final double rating;
  final int mentees;
  final String location;
  final String bio;
  final bool isOnline;

  Mentor(this.name, this.title, this.specialty, this.rating, this.mentees, 
         this.location, this.bio, this.isOnline);
}