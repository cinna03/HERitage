import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import 'package:coursehub/utils/responsive_helper.dart';
import 'goal_setting_screen.dart';

class InterestSelectionScreen extends StatefulWidget {
  @override
  _InterestSelectionScreenState createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> with SingleTickerProviderStateMixin {
  List<String> selectedInterests = [];
  late AnimationController _animationController;

  final List<InterestCategory> categories = [
    InterestCategory('Painting', Icons.brush, 'Traditional and digital painting'),
    InterestCategory('Music', Icons.music_note, 'Instruments, vocals, production'),
    InterestCategory('Photography', Icons.camera_alt, 'Portrait, landscape, commercial'),
    InterestCategory('Design', Icons.design_services, 'Graphic, UI/UX, fashion'),
    InterestCategory('Writing', Icons.edit, 'Creative writing, journalism'),
    InterestCategory('Dance', Icons.sports_kabaddi, 'Traditional, contemporary, choreography'),
    InterestCategory('Crafts', Icons.handyman, 'Jewelry, pottery, textiles'),
    InterestCategory('Film', Icons.movie, 'Directing, editing, cinematography'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600; // ≤5.5" phones
    final isLargeScreen = screenWidth >= 1200; // ≥6.7" tablets
    
    // Responsive grid columns
    final crossAxisCount = isSmallScreen ? 2 : (isLargeScreen ? 3 : 2);
    final spacing = isSmallScreen ? 12.0 : 16.0;
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
          // Material tap target: 48x48dp
          constraints: BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        title: Text(
          'Step 1 of 4',
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontSize: 14,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _animationController,
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with modern typography
                Text(
                  'What interests you?',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 28 : 32,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.headlineLarge?.color,
                    fontFamily: 'Lato',
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Select all art categories that spark your creativity',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 16,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
                // Interest cards grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: isSmallScreen ? 1.0 : 1.1,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedInterests.contains(category.name);
                      
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: value,
                              child: _buildInterestCard(
                                context,
                                category,
                                isSelected,
                                theme,
                                isDark,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                // Continue button with proper Material tap size
                SizedBox(
                  width: double.infinity,
                  height: 56, // Material Design minimum tap target
                  child: ElevatedButton(
                    onPressed: selectedInterests.isNotEmpty ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoalSettingScreen(
                            selectedInterests: selectedInterests,
                          ),
                        ),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedInterests.isNotEmpty 
                          ? primaryPink 
                          : (isDark ? Color(0xFF2D2D2D) : lightPink),
                      foregroundColor: selectedInterests.isNotEmpty 
                          ? white 
                          : (isDark ? Color(0xFF9E9E9E) : mediumGrey),
                      elevation: selectedInterests.isNotEmpty ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
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
      ),
    );
  }

  Widget _buildInterestCard(
    BuildContext context,
    InterestCategory category,
    bool isSelected,
    ThemeData theme,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedInterests.remove(category.name);
            } else {
              selectedInterests.add(category.name);
            }
          });
          // Haptic feedback
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(20),
        // Material tap target: ensure minimum 48x48dp
        child: Container(
          constraints: BoxConstraints(minHeight: 48),
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
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animation
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? white.withValues(alpha: 0.2)
                        : primaryPink.withValues(alpha: isDark ? 0.15 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    size: 32,
                    color: isSelected ? white : primaryPink,
                  ),
                ),
                SizedBox(height: 12),
                // Category name
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected 
                        ? white 
                        : theme.textTheme.titleLarge?.color,
                    fontFamily: 'Lato',
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                // Description
                Text(
                  category.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected 
                        ? white.withValues(alpha: 0.85)
                        : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InterestCategory {
  final String name;
  final IconData icon;
  final String description;

  InterestCategory(this.name, this.icon, this.description);
}