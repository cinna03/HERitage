# HERmony - Empowering African Women in Arts

A comprehensive Flutter application designed to empower African women in creative arts through education, community, and mentorship.

## Features

### 🔐 Authentication
- Email/Password authentication with Firebase
- Google Sign-In integration
- Password reset functionality
- Input validation and error handling

### 🎨 Core Functionality
- **Community Forum**: Create and share posts with real-time updates
- **Events Management**: Browse, RSVP, and join live events
- **Course Learning**: Access educational content and track progress
- **Chat Rooms**: Real-time messaging with other community members
- **Profile Management**: Customize your profile and view achievements

### 🛠 Technical Features
- **State Management**: Provider pattern for scalable state management
- **Database**: Firestore with proper security rules and indexes
- **Responsive Design**: Works on various screen sizes
- **Offline Support**: SharedPreferences for user settings
- **Testing**: Comprehensive unit and widget tests

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.0.0)
- Firebase project setup
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd HERmony
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication (Email/Password and Google)
   - Enable Firestore Database
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place files in respective platform folders

4. **Deploy Firestore Rules**
   ```bash
   firebase deploy --only firestore:rules
   firebase deploy --only firestore:indexes
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── providers/               # State management
│   ├── auth_provider.dart
│   └── forum_provider.dart
├── services/               # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── preferences_service.dart
├── ui/                     # User interface
│   ├── auth/              # Authentication screens
│   ├── community/         # Forum and chat
│   ├── dashboard/         # Main navigation
│   ├── events/           # Events management
│   ├── profile/          # User profile
│   └── settings/         # App settings
├── models/               # Data models
├── utils/               # Utilities and themes
└── widgets/            # Reusable widgets
```

## Testing

Run tests with:
```bash
flutter test
```

Test coverage includes:
- Authentication service tests
- Forum provider tests
- Preferences service tests
- Widget tests for login functionality

## Screenshots

### Authentication Flow
- Login Screen with Email/Password and Google Sign-In
- Sign-Up Screen with validation
- Password Reset Dialog

### Main Features
- Dashboard with progress tracking
- Community Forum with real-time posts
- Events Calendar with RSVP functionality
- Chat Rooms for community interaction
- Profile Management with achievements
- Settings with theme and preferences

## Architecture

### State Management
- **Provider Pattern**: Used for scalable state management
- **Service Layer**: Separates business logic from UI
- **Repository Pattern**: Abstracts data access

### Database Design
- **Users Collection**: User profiles and preferences
- **Posts Collection**: Forum posts with timestamps
- **Events Collection**: Event information and attendees
- **ChatMessages Collection**: Real-time chat messages

### Security
- Firestore security rules restrict access to user data
- Authentication required for all operations
- Input validation on all forms

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.
