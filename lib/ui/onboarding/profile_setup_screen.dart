import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import '../dashboard/dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final List<String> selectedInterests;
  final String selectedGoal;
  final String experienceLevel;

  ProfileSetupScreen({
    required this.selectedInterests,
    required this.selectedGoal,
    required this.experienceLevel,
  });

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;

  void _completeSetup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Save profile data (mock implementation)
        await Future.delayed(Duration(seconds: 1));
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile setup completed successfully!'),
            backgroundColor: successGreen,
          ),
        );
        
        // Navigate to dashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => DashboardScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setup failed. Please try again.'),
            backgroundColor: errorRed,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryPink),
        title: Text(
          'Step 4 of 4',
          style: TextStyle(color: mediumGrey, fontSize: 14),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkGrey,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Let the community get to know you',
                  style: TextStyle(
                    fontSize: 16,
                    color: mediumGrey,
                  ),
                ),
                SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    // Add profile picture
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: lightPink,
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryPink, width: 3),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: primaryPink,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Add Profile Picture',
                  style: TextStyle(
                    color: primaryPink,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person, color: primaryPink),
                    helperText: 'This will be your unique identifier',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Username is required';
                    if (value!.length < 3) return 'Username must be at least 3 characters';
                    return null;
                  },
                ),
                SizedBox(height: 25),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    prefixIcon: Icon(Icons.edit, color: primaryPink),
                    helperText: 'Tell us about yourself and your creative journey',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Bio is required';
                    if (value!.length < 20) return 'Please write at least 20 characters';
                    return null;
                  },
                ),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: lightPink),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Profile Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkGrey,
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildSummaryItem('Interests', widget.selectedInterests.join(', ')),
                      _buildSummaryItem('Goal', widget.selectedGoal),
                      _buildSummaryItem('Level', widget.experienceLevel),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeSetup,
                    child: _isLoading 
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(white),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Setting up...', style: TextStyle(fontSize: 16)),
                            ],
                          )
                        : Text('Complete Setup', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
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

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: primaryPink,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: darkGrey),
            ),
          ),
        ],
      ),
    );
  }
}