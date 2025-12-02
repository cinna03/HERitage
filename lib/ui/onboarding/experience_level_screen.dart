import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/responsive_helper.dart';
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
          'Step 3 of 4',
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
                'What\'s your experience level?',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'This helps us recommend the right content for you',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    final isSelected = selectedLevel == level.title;
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedLevel = level.title;
                            });
                            HapticFeedback.selectionClick();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(24),
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
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? white.withValues(alpha: 0.2)
                                        : primaryPink.withValues(alpha: isDark ? 0.15 : 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    level.icon,
                                    color: isSelected ? white : primaryPink,
                                    size: 32,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        level.title,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: isSelected 
                                              ? white 
                                              : theme.textTheme.titleLarge?.color,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        level.description,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: isSelected 
                                              ? white.withValues(alpha: 0.9)
                                              : theme.textTheme.bodyMedium?.color,
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        level.subtitle,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isSelected 
                                              ? white.withValues(alpha: 0.7)
                                              : theme.textTheme.bodySmall?.color,
                                          fontSize: 12,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedLevel != null 
                        ? primaryPink 
                        : (isDark ? Color(0xFF2D2D2D) : lightPink),
                    foregroundColor: selectedLevel != null 
                        ? white 
                        : (isDark ? Color(0xFF9E9E9E) : mediumGrey),
                    elevation: selectedLevel != null ? 2 : 0,
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

class ExperienceLevel {
  final String title;
  final String description;
  final String subtitle;
  final IconData icon;

  ExperienceLevel(this.title, this.description, this.subtitle, this.icon);
}