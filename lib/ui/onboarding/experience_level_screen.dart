import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import 'profile_setup_screen.dart';

class ExperienceLevelScreen extends StatefulWidget {
  final List<String> selectedInterests;
  final String selectedGoal;

  ExperienceLevelScreen({
    required this.selectedInterests,
    required this.selectedGoal,
  });

  @override
  _ExperienceLevelScreenState createState() => _ExperienceLevelScreenState();
}

class _ExperienceLevelScreenState extends State<ExperienceLevelScreen> {
  String? selectedLevel;

  final List<ExperienceLevel> levels = [
    ExperienceLevel(
      'Beginner',
      'I\'m just starting my creative journey',
      'New to most creative skills',
      Icons.star_border,
    ),
    ExperienceLevel(
      'Intermediate',
      'I have some experience and want to improve',
      'Familiar with basics, ready to advance',
      Icons.star_half,
    ),
    ExperienceLevel(
      'Advanced',
      'I have solid skills and want to master them',
      'Experienced, seeking specialization',
      Icons.star,
    ),
    ExperienceLevel(
      'Professional',
      'I work in creative fields and want to expand',
      'Already working professionally',
      Icons.workspace_premium,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryPink),
        title: Text(
          'Step 3 of 4',
          style: TextStyle(color: mediumGrey, fontSize: 14),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What\'s your experience level?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'This helps us recommend the right content for you',
                style: TextStyle(
                  fontSize: 16,
                  color: mediumGrey,
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    final isSelected = selectedLevel == level.title;
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedLevel = level.title;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryPink : white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? primaryPink : lightPink,
                              width: 2,
                            ),
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
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isSelected ? white : primaryPink.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  level.icon,
                                  color: isSelected ? primaryPink : primaryPink,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? white : darkGrey,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      level.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected ? white.withOpacity(0.9) : mediumGrey,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      level.subtitle,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected ? white.withOpacity(0.7) : mediumGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: white,
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedLevel != null ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSetupScreen(
                          selectedInterests: widget.selectedInterests,
                          selectedGoal: widget.selectedGoal,
                          experienceLevel: selectedLevel!,
                        ),
                      ),
                    );
                  } : null,
                  child: Text('Continue', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: selectedLevel != null ? primaryPink : lightPink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExperienceLevel {
  final String title;
  final String description;
  final String subtitle;
  final IconData icon;

  ExperienceLevel(this.title, this.description, this.subtitle, this.icon);
}