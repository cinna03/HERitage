import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import '../../utils/error_handler.dart';
import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../providers/user_stats_provider.dart';

class CourseContentScreen extends StatefulWidget {
  final Course course;
  final String? courseId; // Firestore document ID

  CourseContentScreen({required this.course, this.courseId});

  @override
  _CourseContentScreenState createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  int currentLessonIndex = 0;
  double progress = 0.0;

  final List<Lesson> lessons = [
    Lesson('Welcome & Introduction', 'Get started with your creative journey', 5, true),
    Lesson('Setting Up Your Workspace', 'Prepare your tools and environment', 8, true),
    Lesson('Basic Techniques', 'Learn fundamental skills', 12, false),
    Lesson('Color Theory Basics', 'Understanding colors and harmony', 15, false),
    Lesson('Composition Principles', 'Creating balanced artwork', 18, false),
    Lesson('Practice Exercise 1', 'Apply what you\'ve learned', 20, false),
    Lesson('Advanced Techniques', 'Take your skills to the next level', 25, false),
    Lesson('Style Development', 'Find your unique voice', 22, false),
    Lesson('Portfolio Building', 'Create professional work', 30, false),
    Lesson('Final Project', 'Showcase your skills', 35, false),
  ];

  @override
  void initState() {
    super.initState();
    _calculateProgress();
    // Load course progress if courseId is provided
    if (widget.courseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<CourseProvider>(context, listen: false)
            .loadCourse(widget.courseId!);
      });
    }
  }

  void _calculateProgress() {
    int completedLessons = lessons.where((lesson) => lesson.isCompleted).length;
    progress = completedLessons / lessons.length;
  }

  Future<void> _updateProgress(int lessonIndex) async {
    if (widget.courseId == null) return;
    
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final newProgress = ((lessonIndex + 1) / lessons.length * 100).round();
    
    try {
      await courseProvider.updateProgress(widget.courseId!, newProgress);
      _calculateProgress();
      
      // Refresh user statistics after progress update
      final statsProvider = Provider.of<UserStatsProvider>(context, listen: false);
      await statsProvider.refresh();
    } catch (e) {
      ErrorHandler.showError(context, e);
    }
  }

  Future<void> _markCourseComplete() async {
    if (widget.courseId == null) return;
    
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    
    try {
      await courseProvider.markComplete(widget.courseId!);
      
      // Refresh user statistics after course completion
      final statsProvider = Provider.of<UserStatsProvider>(context, listen: false);
      await statsProvider.refresh();
      
      ErrorHandler.showSuccess(context, '🎉 Congratulations! Course completed! Certificate earned.');
    } catch (e) {
      ErrorHandler.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        title: Text(widget.course.title),
        backgroundColor: primaryPink,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.bookmark_border),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressHeader(),
          Expanded(child: _buildLessonsList()),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        // Use Firestore progress if available, otherwise use local progress
        double displayProgress = progress;
        bool isCompleted = false;
        
        if (widget.courseId != null && courseProvider.userProgress != null) {
          displayProgress = (courseProvider.userProgress!['progress'] as num? ?? 0).toDouble() / 100;
          isCompleted = courseProvider.userProgress!['completed'] == true;
        } else {
          isCompleted = progress == 1.0;
        }

        return Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: primaryPink,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Course Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                  Text(
                    '${(displayProgress * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 16,
                      color: white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              LinearProgressIndicator(
                value: displayProgress,
                backgroundColor: white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(white),
                minHeight: 8,
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressStat('Lessons', '${lessons.where((l) => l.isCompleted).length}/${lessons.length}'),
                  _buildProgressStat('Time Left', '${_calculateTimeLeft()} min'),
                  _buildProgressStat('Certificate', isCompleted ? 'Ready' : 'In Progress'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonsList() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final isCurrentLesson = index == currentLessonIndex;
        final isAccessible = index == 0 || lessons[index - 1].isCompleted;
        
        return Container(
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(15),
            border: isCurrentLesson ? Border.all(color: primaryPink, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: lightPink.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(20),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: lesson.isCompleted 
                    ? successGreen 
                    : isAccessible 
                        ? primaryPink.withValues(alpha: 0.1) 
                        : lightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                lesson.isCompleted 
                    ? Icons.check 
                    : isAccessible 
                        ? Icons.play_arrow 
                        : Icons.lock,
                color: lesson.isCompleted 
                    ? white 
                    : isAccessible 
                        ? primaryPink 
                        : mediumGrey,
              ),
            ),
            title: Text(
              lesson.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isAccessible ? darkGrey : mediumGrey,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text(
                  lesson.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isAccessible ? mediumGrey : lightGrey,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: mediumGrey),
                    SizedBox(width: 4),
                    Text(
                      '${lesson.duration} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: mediumGrey,
                      ),
                    ),
                    if (lesson.isCompleted) ...[
                      SizedBox(width: 15),
                      Icon(Icons.check_circle, size: 16, color: successGreen),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: isAccessible ? Icon(Icons.chevron_right, color: primaryPink) : null,
            onTap: isAccessible ? () {
              setState(() {
                currentLessonIndex = index;
              });
              _showLessonContent(lesson, index);
            } : null,
          ),
        );
      },
    );
  }

  void _showLessonContent(Lesson lesson, int index) {
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
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryPink,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${lesson.duration} minutes',
                          style: TextStyle(
                            fontSize: 14,
                            color: white.withValues(alpha: 0.8),
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: lightGrey,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_filled, size: 60, color: primaryPink),
                            SizedBox(height: 10),
                            Text('Video Content', style: TextStyle(color: mediumGrey)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Lesson Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      lesson.description + '. In this lesson, you\'ll dive deep into the concepts and practice hands-on exercises to master the skills.',
                      style: TextStyle(
                        fontSize: 14,
                        color: mediumGrey,
                        height: 1.5,
                      ),
                    ),
                    Spacer(),
                    if (!lesson.isCompleted)
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              lessons[index].isCompleted = true;
                              _calculateProgress();
                            });
                            
                            // Update progress in Firestore
                            await _updateProgress(index);
                            
                            // Check if course is complete
                            if (progress >= 1.0 && widget.courseId != null) {
                              await _markCourseComplete();
                            }
                            
                            Navigator.pop(context);
                            ErrorHandler.showSuccess(context, 'Lesson completed!');
                          },
                          child: Text('Mark as Complete'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTimeLeft() {
    return lessons.where((lesson) => !lesson.isCompleted)
                  .fold(0, (sum, lesson) => sum + lesson.duration);
  }
}

class Lesson {
  final String title;
  final String description;
  final int duration;
  bool isCompleted;

  Lesson(this.title, this.description, this.duration, this.isCompleted);
}