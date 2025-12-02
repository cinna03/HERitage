import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import '../../widgets/loading_overlay.dart';
import '../../providers/course_provider.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Courses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
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
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.all(20),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search courses...',
          hintStyle: theme.textTheme.bodyMedium,
          prefixIcon: Icon(Icons.search, color: primaryPink),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
              backgroundColor: theme.cardColor,
              selectedColor: primaryPink,
              labelStyle: TextStyle(
                color: isSelected ? white : theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lato',
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
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        // Use Firestore courses if available, otherwise use local courses
        final availableCourses = courseProvider.courses.isNotEmpty 
            ? courseProvider.courses 
            : courses.map((c) => {
                'title': c.title,
                'description': c.description,
                'category': c.category,
                'rating': c.rating,
                'students': c.students,
                'level': c.level,
              }).toList();

        final filteredCourses = availableCourses.where((course) {
          final title = course['title'] ?? '';
          final desc = course['description'] ?? '';
          final cat = course['category'] ?? '';
          final matchesCategory = selectedCategory == 'All' || cat == selectedCategory;
          final matchesSearch = title.toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                               desc.toString().toLowerCase().contains(searchQuery.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();

        if (courseProvider.isLoading && filteredCourses.isEmpty) {
          return LoadingIndicator(message: 'Loading courses...');
        }

        if (filteredCourses.isEmpty) {
          return EmptyState(
            icon: Icons.school,
            title: 'No courses found',
            message: searchQuery.isNotEmpty 
                ? 'Try a different search term'
                : 'No courses available in this category',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(20),
          itemCount: filteredCourses.length,
          itemBuilder: (context, index) {
            final courseData = filteredCourses[index];
            final course = Course(
              courseData['title']?.toString() ?? 'Untitled',
              courseData['description']?.toString() ?? '',
              courseData['category']?.toString() ?? 'General',
              (courseData['rating'] as num?)?.toDouble() ?? 0.0,
              (courseData['students'] as num?)?.toInt() ?? 0,
              courseData['level']?.toString() ?? 'Beginner',
            );
            return _buildCourseCard(course, courseData['id']?.toString());
          },
        );
      },
    );
  }

  Widget _buildCourseCard(Course course, String? courseId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
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
              builder: (context) => CourseDetailScreen(
                course: course,
                courseId: courseId,
              ),
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
                color: primaryPink.withValues(alpha: 0.1),
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
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryPink.withValues(alpha: 0.1),
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        course.rating.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 15),
                      Icon(Icons.people, color: theme.iconTheme.color?.withValues(alpha: 0.6), size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${course.students} students',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
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

