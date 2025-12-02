import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/responsive_helper.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final padding = ResponsiveHelper.getResponsivePadding(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: theme.iconTheme.color,
          onPressed: () => Navigator.pop(context),
          constraints: BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        title: Text(
          'Step 2 of 4',
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontSize: 14,
            fontFamily: 'Lato',
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What do you want to achieve?',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Choose your primary goal to personalize your experience',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final isSelected = selectedGoal == goal.title;
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedGoal = goal.title;
                            });
                            HapticFeedback.selectionClick();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? primaryPink 
                                  : (isDark ? Color(0xFF2D2D2D) : white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? primaryPink 
                                    : (isDark ? Color(0xFF404040) : lightPink),
                                width: isSelected ? 2.5 : 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryPink.withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? white.withValues(alpha: 0.2)
                                        : primaryPink.withValues(alpha: isDark ? 0.15 : 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    goal.icon,
                                    color: isSelected ? white : primaryPink,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal.title,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: isSelected 
                                              ? white 
                                              : theme.textTheme.titleLarge?.color,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        goal.description,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: isSelected 
                                              ? white.withValues(alpha: 0.85)
                                              : theme.textTheme.bodyMedium?.color,
                                          height: 1.3,
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
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedGoal != null 
                        ? primaryPink 
                        : (isDark ? Color(0xFF2D2D2D) : lightPink),
                    foregroundColor: selectedGoal != null 
                        ? white 
                        : (isDark ? Color(0xFF9E9E9E) : mediumGrey),
                    elevation: selectedGoal != null ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lato',
                      letterSpacing: 0.5,
                    ),
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