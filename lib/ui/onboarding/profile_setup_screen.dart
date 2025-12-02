import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/responsive_helper.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../utils/error_handler.dart';
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
  final _imagePicker = ImagePicker();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _authService = AuthService();
  File? _profileImage;
  bool _isLoading = false;

  void _completeSetup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final user = _authService.currentUser;
        if (user == null) {
          throw Exception('User must be authenticated to complete profile setup');
        }

        String? profilePictureUrl;
        
        // Upload profile picture if selected
        if (_profileImage != null && !kIsWeb) {
          try {
            profilePictureUrl = await _storageService.uploadProfilePicture(user.uid, _profileImage!);
          } catch (e) {
            // Continue even if image upload fails
            print('Failed to upload profile picture: $e');
          }
        }

        // Prepare user profile data
        final username = _usernameController.text.trim();
        final userData = {
          'username': username,
          'bio': _bioController.text.trim(),
          'interests': widget.selectedInterests,
          'goal': widget.selectedGoal,
          'experienceLevel': widget.experienceLevel,
          'profilePictureUrl': profilePictureUrl,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        // Save profile to Firestore
        await _firestoreService.createUserProfile(user.uid, userData);
        
        // Update Firebase Auth display name with username
        try {
          if (username.isNotEmpty) {
            await user.updateProfile(displayName: username);
            await user.reload();
          }
        } catch (e) {
          // Continue even if display name update fails
          print('Failed to update display name: $e');
        }
        
        // Show success message
        ErrorHandler.showSuccess(context, 'Profile setup completed successfully!');
        
        // Navigate to dashboard
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => DashboardScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        ErrorHandler.showError(context, e);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

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
          'Step 4 of 4',
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontSize: 14,
            fontFamily: 'Lato',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Complete Your Profile',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Let the community get to know you',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 40),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _pickProfileImage(),
                    borderRadius: BorderRadius.circular(60),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF2D2D2D) : lightPink,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryPink, width: 3),
                      ),
                      child: _profileImage != null && !kIsWeb
                          ? ClipOval(
                              child: Image.file(
                                _profileImage!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: primaryPink,
                            ),
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
                    // Bio is optional - users can have a bio as small as 1 emoji
                    return null;
                  },
                ),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Color(0xFF404040) : lightPink,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Profile Summary',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeSetup,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
                              Text(
                                'Setting up...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Complete Setup',
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

  Widget _buildSummaryItem(String label, String value) {
    final theme = Theme.of(context);
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
              fontFamily: 'Lato',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Lato',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      HapticFeedback.selectionClick();
      
      if (kIsWeb) {
        // For web, show a message that image upload will be available soon
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload on web will be available soon. You can add a profile picture later.'),
              backgroundColor: primaryPink,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: errorRed,
          ),
        );
      }
    }
  }
}