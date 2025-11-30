import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import 'goal_setting_screen.dart';

class InterestSelectionScreen extends StatefulWidget {
  @override
  _InterestSelectionScreenState createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  List<String> selectedInterests = [];

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryPink),
        title: Text(
          'Step 1 of 4',
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
                'What interests you?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Select all art categories that spark your creativity',
                style: TextStyle(
                  fontSize: 16,
                  color: mediumGrey,
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedInterests.contains(category.name);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedInterests.remove(category.name);
                          } else {
                            selectedInterests.add(category.name);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? primaryPink : white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? primaryPink : lightPink,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category.icon,
                              size: 40,
                              color: isSelected ? white : primaryPink,
                            ),
                            SizedBox(height: 10),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? white : darkGrey,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              category.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? white.withOpacity(0.8) : mediumGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
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
                  child: Text('Continue', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: selectedInterests.isNotEmpty ? primaryPink : lightPink,
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

class InterestCategory {
  final String name;
  final IconData icon;
  final String description;

  InterestCategory(this.name, this.icon, this.description);
}