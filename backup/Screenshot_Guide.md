# HERmony App Screenshot Guide

## Required Screenshots for the Report

Based on the sample report format, you'll need to capture the following screenshots to complete your report. These should be taken on a physical device or emulator (NOT web/desktop builds).

### 1. Use Case Diagram (Figure 1)
- Create a use case diagram showing:
  - User actors (Regular User, Admin)
  - Main use cases: Login/Register, View Dashboard, Access Courses, Participate in Community, Manage Profile, Attend Events, Use Chat Rooms
  - System boundary for HERmony app
  - Relationships between actors and use cases

### 2. Application Flowchart (Figure 2)
- Create a flowchart showing:
  - App launch → Splash Screen
  - Authentication flow (Login/Register/Forgot Password)
  - Main navigation flow between different sections
  - Decision points and user paths
  - Logout process

### 3. UI Screenshots (Figure 3) - CRITICAL
Take screenshots of these screens running on a mobile device/emulator:

**Authentication Screens:**
- Splash screen
- Login screen
- Registration screen
- Email verification screen (if applicable)
- Forgot password screen

**Main App Screens:**
- Dashboard/Home screen
- Community forum screen
- Events listing screen
- Course catalog screen
- Profile screen
- Settings screen
- Chat room screen

**Additional Screens:**
- Course detail screen
- Event detail screen
- Profile editing screen
- Any onboarding screens

### 4. Architecture Diagrams

**Provider Pattern Architecture (Figure 4):**
- Create a diagram showing:
  - UI Layer (Widgets)
  - Provider Layer (AuthProvider, ForumProvider, ThemeProvider)
  - Service Layer (AuthService, FirestoreService)
  - Data Layer (Firebase, SharedPreferences)

**File Structure (Figure 5):**
- Screenshot of your project's file structure in VS Code/Android Studio
- Show the organized lib folder with subdirectories

### 5. Code Implementation Screenshots

**MultiProvider Setup (Figure 6):**
- Screenshot of main.dart showing MultiProvider implementation

**AuthProvider Functions (Figure 7):**
- Screenshot of key functions in auth_provider.dart

**Firebase Implementation (Figure 8):**
- Screenshot of Firebase configuration and authentication code

**Firestore Implementation (Figure 9):**
- Screenshot of Firestore service implementation

### 6. Development Process Screenshots

**Development Tools (Figure 11):**
- Screenshot of your development environment (VS Code/Android Studio)
- Flutter doctor output
- Project setup

**Dependencies (Figure 12):**
- Screenshot of pubspec.yaml file showing dependencies

### 7. Testing Screenshots

**Test Code (Figure 17-18):**
- Screenshot of your test files (auth_test.dart, widget_test.dart)
- Show test cases and structure

**Test Results (Figure 19):**
- Screenshot of successful test execution
- Terminal output showing "All tests passed"

## How to Take Screenshots

### For Mobile Device:
1. Run your app on a physical Android/iOS device
2. Navigate to each screen
3. Take screenshots using device's screenshot function
4. Transfer screenshots to your computer

### For Emulator:
1. Start Android Emulator or iOS Simulator
2. Run `flutter run` to launch your app
3. Navigate through the app
4. Take screenshots using emulator's screenshot tool
5. Save screenshots with descriptive names

### For Code Screenshots:
1. Open files in your IDE
2. Ensure code is properly formatted (`dart format`)
3. Use IDE's screenshot feature or system screenshot
4. Crop to show relevant code sections

## Screenshot Organization

Create a folder structure:
```
screenshots/
├── ui_screens/
│   ├── splash_screen.png
│   ├── login_screen.png
│   ├── dashboard_screen.png
│   └── ...
├── architecture/
│   ├── use_case_diagram.png
│   ├── app_flowchart.png
│   └── provider_architecture.png
├── code/
│   ├── main_dart.png
│   ├── auth_provider.png
│   └── ...
└── testing/
    ├── test_code.png
    └── test_results.png
```

## Important Notes

1. **NO WEB/DESKTOP BUILDS**: Only use mobile device or emulator screenshots
2. **High Quality**: Ensure screenshots are clear and readable
3. **Consistent Sizing**: Try to maintain consistent dimensions
4. **Professional Appearance**: Clean, well-organized screenshots
5. **Proper Naming**: Use descriptive filenames for easy identification

## Creating Diagrams

For use case diagrams and flowcharts, you can use:
- Draw.io (free online tool)
- Lucidchart
- Microsoft Visio
- Any diagramming tool of your choice

Export diagrams as high-quality PNG or JPG files.

## Final Steps

1. Take all required screenshots
2. Create necessary diagrams
3. Insert images into the report document
4. Ensure all figures are properly numbered and referenced
5. Convert the final document to PDF format
6. Name the file: `Group#_Final_Project_Submission.pdf`

Remember: The demo video should be 10-15 minutes showcasing major functionalities, CRUD operations, and authentication flows with all team members presenting different aspects of the project.