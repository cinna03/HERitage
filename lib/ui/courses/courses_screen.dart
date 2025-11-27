import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import '../../models/course.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';

  final List<String> categories = [
    'All', 'Painting', 'Music', 'Photography', 'Design', 'Writing', 'Dance', 'Crafts'
  ];

  final List<Course> courses = [
    Course('Digital Painting Fundamentals', 'Learn the basics of digital art', 'Painting', 4.8, 120, 'Beginner'),
    Course('Music Production Basics', 'Create your first track', 'Music', 4.7, 89, 'Beginner'),
    Course('Portrait Photography', 'Master portrait techniques', 'Photography', 4.9, 156, 'Intermediate'),
    Course('UI/UX Design Principles', 'Design beautiful interfaces', 'Design', 4.6, 203, 'Intermediate'),
    Course('Creative Writing Workshop', 'Tell compelling stories', 'Writing', 4.8, 67, 'Beginner'),
    Course('Contemporary Dance', 'Express through movement', 'Dance', 4.7, 45, 'Beginner'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        title: Text('Courses', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryPink,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildCoursesList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(20),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search courses...',
          prefixIcon: Icon(Icons.search, color: primaryPink),
          filled: true,
          fillColor: white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return Container(
            margin: EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
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

  Widget _buildCoursesList() {
    final filteredCourses = courses.where((course) {
      final matchesCategory = selectedCategory == 'All' || course.category == selectedCategory;
      final matchesSearch = course.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                           course.description.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildCourseCard(Course course) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(course.category),
                  size: 50,
                  color: primaryPink,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkGrey,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          course.level,
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    course.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: mediumGrey,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        course.rating.toString(),
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
                        '${course.students} students',
                        style: TextStyle(
                          fontSize: 14,
                          color: mediumGrey,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'FREE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: successGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

