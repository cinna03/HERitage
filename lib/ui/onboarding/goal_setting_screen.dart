import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import 'experience_level_screen.dart';

class GoalSettingScreen extends StatefulWidget {
  final List<String> selectedInterests;

  GoalSettingScreen({required this.selectedInterests});

  @override
  _GoalSettingScreenState createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  String? selectedGoal;

  final List<Goal> goals = [
    Goal(
      'Learn New Skills',
      'I want to explore and master new creative techniques',
      Icons.school,
    ),
    Goal(
      'Build a Portfolio',
      'I want to create professional work to showcase my talent',
      Icons.folder,
    ),
    Goal(
      'Start a Business',
      'I want to turn my creativity into a sustainable income',
      Icons.business,
    ),
    Goal(
      'Find Mentorship',
      'I want guidance from experienced professionals',
      Icons.people,
    ),
    Goal(
      'Join Community',
      'I want to connect with other creative women',
      Icons.group,
    ),
    Goal(
      'Career Change',
      'I want to transition into the creative industry',
      Icons.trending_up,
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
          'Step 2 of 4',
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
                'What do you want to achieve?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Choose your primary goal to personalize your experience',
                style: TextStyle(
                  fontSize: 16,
                  color: mediumGrey,
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final isSelected = selectedGoal == goal.title;
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGoal = goal.title;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryPink : white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? primaryPink : lightPink,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected ? white : primaryPink.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  goal.icon,
                                  color: isSelected ? primaryPink : primaryPink,
                                  size: 25,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? white : darkGrey,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      goal.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected ? white.withOpacity(0.8) : mediumGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: white,
                                  size: 24,
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
                  onPressed: selectedGoal != null ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExperienceLevelScreen(
                          selectedInterests: widget.selectedInterests,
                          selectedGoal: selectedGoal!,
                        ),
                      ),
                    );
                  } : null,
                  child: Text('Continue', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: selectedGoal != null ? primaryPink : lightPink,
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

class Goal {
  final String title;
  final String description;
  final IconData icon;

  Goal(this.title, this.description, this.icon);
}