import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import '../../models/course.dart';
import 'course_content_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  CourseDetailScreen({required this.course});

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
                child: Center(
                  child: Icon(
                    _getCategoryIcon(course.category),
                    size: 80,
                    color: white,
                  ),
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
                    _buildCourseHeader(),
                    SizedBox(height: 25),
                    _buildCourseStats(),
                    SizedBox(height: 25),
                    _buildDescription(),
                    SizedBox(height: 25),
                    _buildWhatYouLearn(),
                    SizedBox(height: 25),
                    _buildInstructor(),
                    SizedBox(height: 25),
                    _buildCurriculum(),
                    SizedBox(height: 30),
                    _buildEnrollButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                course.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                course.level,
                style: TextStyle(
                  fontSize: 14,
                  color: primaryPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          course.description,
          style: TextStyle(
            fontSize: 16,
            color: mediumGrey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseStats() {
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(Icons.star, course.rating.toString(), 'Rating'),
          ),
          Expanded(
            child: _buildStatItem(Icons.people, '${course.students}', 'Students'),
          ),
          Expanded(
            child: _buildStatItem(Icons.access_time, '8 hours', 'Duration'),
          ),
          Expanded(
            child: _buildStatItem(Icons.play_circle, '24', 'Lessons'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: primaryPink, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: darkGrey,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: mediumGrey,
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
          'About This Course',
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
            'This comprehensive course will take you from beginner to confident practitioner. You\'ll learn fundamental techniques, explore creative processes, and build a strong foundation in ${course.category.toLowerCase()}. Perfect for anyone looking to start their creative journey or enhance existing skills.',
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

  Widget _buildWhatYouLearn() {
    final learningPoints = [
      'Master fundamental techniques and principles',
      'Develop your unique creative style',
      'Build a professional portfolio',
      'Connect with industry mentors',
      'Access exclusive resources and tools',
      'Join a supportive community of learners',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What You\'ll Learn',
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
          child: Column(
            children: learningPoints.map((point) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: successGreen, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 14,
                          color: darkGrey,
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

  Widget _buildInstructor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Instructor',
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
                      'Amara Johnson',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Professional Artist & Mentor',
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '10+ years experience, 50k+ students taught',
                      style: TextStyle(
                        fontSize: 12,
                        color: mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurriculum() {
    final modules = [
      'Introduction & Getting Started',
      'Basic Techniques & Tools',
      'Color Theory & Composition',
      'Advanced Techniques',
      'Portfolio Development',
      'Final Project & Certification',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Curriculum',
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
            children: modules.asMap().entries.map((entry) {
              final index = entry.key;
              final module = entry.value;
              final isLast = index == modules.length - 1;
              
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
                        module,
                        style: TextStyle(
                          fontSize: 14,
                          color: darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.play_circle_outline, color: primaryPink),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseContentScreen(course: course),
            ),
          );
        },
        child: Text('Enroll Now - FREE', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          backgroundColor: primaryPink,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Painting': return Icons.brush;
      case 'Music': return Icons.music_note;
      case 'Photography': return Icons.camera_alt;
      case 'Design': return Icons.design_services;
      case 'Writing': return Icons.edit;
      case 'Dance': return Icons.sports_kabaddi;
      case 'Crafts': return Icons.handyman;
      default: return Icons.school;
    }
  }
}