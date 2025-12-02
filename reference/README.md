# HERitage (HERmony)

Online E-Learning App for Empowering African Women in Arts

# Screenshots

## App Screenshots

The following screenshots demonstrate the key features of the HERmony app:

### Authentication & Onboarding
- **Create Account Screen**: User registration with email/password validation
- **Login Screen**: Email/password and Google Sign-In options with password reset
- **Email Verification Screen**: Email verification flow after signup
- **Onboarding Screens**: Interest selection, experience level, and goal setting

### Main App Features
- **Home/Dashboard Screen**: Personalized dashboard with quick actions, featured courses, and progress tracking
- **Courses Screen**: Browse and search courses by category with filtering
- **Course Detail Screen**: Course information, enrollment, and progress tracking
- **Course Content Screen**: Lesson navigation and completion tracking
- **Community/Forum Screen**: Real-time forum posts, chat rooms, and mentors
- **Chat Room Screen**: Real-time messaging within chat rooms
- **Events Screen**: Upcoming, live, and past events with RSVP functionality
- **Profile Screen**: User profile with statistics and settings

### Design Features
- **Responsive Design**: Works on phones (≤5.5") and tablets (≥6.7")
- **Dark/Light Theme**: Theme switching with persistence
- **Material Design**: Follows Material Design guidelines with proper tap targets

> **Note:** To add screenshots, place image files in the `docs/screenshots/` directory and reference them using markdown image syntax:
> ```markdown
> ![Create Account](docs/screenshots/create_account.png) | ![Login](docs/screenshots/login.png)
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
