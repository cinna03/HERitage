# HERitage (HERmony)

Online E-Learning App for Empowering African Women in Arts

# Screenshots

This section outlines all the screenshots that should be included in the README to showcase the app's features and setup process.

## Setup Screenshots

These screenshots help users understand the setup process:

### Firebase Console Setup
1. **Firebase Project Creation**: Screenshot of Firebase Console showing project creation
2. **Firebase Project Settings**: Screenshot showing the project settings page with app configuration
3. **Authentication Setup**: Screenshot of Authentication > Sign-in method showing Email/Password and Google enabled
4. **Firestore Database Creation**: Screenshot showing Firestore database creation and location selection
5. **Firestore Security Rules**: Screenshot of the Firestore Rules editor (optional, but helpful)
6. **FlutterFire CLI Configuration**: Terminal screenshot showing `flutterfire configure` command execution
7. **Android Configuration**: Screenshot showing `google-services.json` file location in project structure
8. **iOS Configuration**: Screenshot showing `GoogleService-Info.plist` file location in project structure

### Development Setup
9. **Flutter Installation Check**: Terminal screenshot showing `flutter doctor` output
10. **Dependencies Installation**: Terminal screenshot showing `flutter pub get` execution
11. **App Running**: Screenshot of the app running on emulator/device (splash screen or first screen)

## App Screenshots

The following screenshots demonstrate the key features of the HERmony app:

### Authentication & Onboarding
1. **Welcome Screen**: Initial welcome screen with app branding
2. **Login Screen**: Email/password and Google Sign-In options with password reset link
3. **Create Account Screen**: User registration form with email/password validation
4. **Email Verification Screen**: Email verification prompt after signup
5. **Forgot Password Screen**: Password reset flow
6. **Interest Selection Screen**: Onboarding screen for selecting user interests
7. **Experience Level Screen**: Onboarding screen for selecting experience level
8. **Goal Setting Screen**: Onboarding screen for setting learning goals
9. **Profile Setup Screen**: Initial profile creation screen

### Main App Features - Dashboard & Navigation
10. **Home/Dashboard Screen**: Personalized dashboard with quick actions, featured courses, and progress tracking
11. **Bottom Navigation Bar**: Screenshot showing the main navigation (Home, Courses, Community, Events, Profile)
12. **Dashboard - Calendar Tab**: Calendar view with events and reminders
13. **Dashboard - Statistics**: User statistics and progress overview

### Courses & Learning
14. **Courses Screen**: Browse and search courses by category with filtering options
15. **Course Detail Screen**: Course information, enrollment button, instructor details, and progress tracking
16. **Course Content Screen**: Lesson list with navigation and completion tracking
17. **Single Lesson Screen**: Individual lesson view with video/content and navigation
18. **Course Progress**: Screenshot showing course completion progress

### Community & Social
19. **Community/Forum Screen**: Real-time forum posts list with categories
20. **Forum Post Detail**: Individual post with comments and interactions
21. **Create Post Screen**: Post creation form
22. **Chat Rooms Screen**: List of available chat rooms
23. **Chat Room Screen**: Real-time messaging within a chat room
24. **Direct Messaging Screen**: User search and direct message conversations
25. **Mentors Screen**: List of available mentors

### Events
26. **Events Screen**: Upcoming, live, and past events with filtering
27. **Event Detail Screen**: Event information with RSVP functionality
28. **Add Event Screen**: Event creation form

### Profile & Settings
29. **Profile Screen**: User profile with statistics, achievements, and edit options
30. **Settings Screen**: Settings menu with theme, language, and notification preferences
31. **Notifications Screen**: List of user notifications
32. **User Statistics**: Detailed statistics view

### Design Features
33. **Dark Theme**: Screenshot showing the app in dark mode (any main screen)
34. **Light Theme**: Screenshot showing the app in light mode (same screen as dark theme for comparison)
35. **Responsive Design - Phone**: Screenshot on a phone (≤5.5") showing mobile layout
36. **Responsive Design - Tablet**: Screenshot on a tablet (≥6.7") showing tablet layout
37. **Material Design Elements**: Close-up screenshot showing Material Design components (buttons, cards, etc.)

## Screenshot Organization

> **Note:** Place all screenshot files in the `docs/screenshots/` directory with descriptive filenames:
> - Setup screenshots: `setup_firebase_project.png`, `setup_auth_enabled.png`, etc.
> - App screenshots: `welcome_screen.png`, `login_screen.png`, `dashboard_screen.png`, etc.
> 
> Reference them in markdown using:
> ```markdown
> ![Description](docs/screenshots/filename.png)
> ```
> 
> For side-by-side comparisons:
> ```markdown
> ![Light Theme](docs/screenshots/light_theme.png) | ![Dark Theme](docs/screenshots/dark_theme.png)
> ```

## Getting Started

This project is a starting point for a Flutter application.

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase account

### Firebase Setup

**⚠️ IMPORTANT:** This app requires Firebase configuration to function properly.

Before running the app, you must:
1. Set up a Firebase project
2. Configure Firebase for your app

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions.

**Quick Start:**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (requires Firebase login)
firebase login
flutterfire configure
```

**Note:** The iOS bundle identifier is `co.zw.coursehub` (not `com.example.coursehub`). Make sure to use the correct bundle ID when setting up Firebase.

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase (see FIREBASE_SETUP.md)
4. Run the app:
   ```bash
   flutter run
   ```

## Features

- User Authentication (Email/Password & Google Sign-In)
- Firestore Database Integration
- Forum/Discussion Posts
- Events Management
- Responsive UI Design

## Project Structure

- `lib/` - Main application code
  - `services/` - Firebase services (Auth, Firestore)
  - `providers/` - State management
  - `ui/` - UI screens
  - `models/` - Data models
  - `widgets/` - Reusable widgets

## Resources

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
- [Firebase for Flutter](https://firebase.flutter.dev/)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
