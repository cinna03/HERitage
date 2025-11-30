# Firebase Setup Instructions

## Prerequisites
1. Create a Firebase project at https://console.firebase.google.com/
2. Enable Authentication with Email/Password and Google Sign-In
3. Create a Firestore database

## Quick Setup (Recommended - Using FlutterFire CLI)

### Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 2: Configure Firebase for your project
```bash
flutterfire configure
```

This will:
- Generate `lib/firebase_options.dart` with your actual Firebase configuration
- Automatically download and configure `google-services.json` for Android
- Automatically download and configure `GoogleService-Info.plist` for iOS
- Update all necessary configuration files

**Note:** You need to be logged into Firebase CLI. If prompted, run:
```bash
firebase login
```

---

## Manual Setup (Alternative Method)

If FlutterFire CLI doesn't work, follow these manual steps:

### Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Add project" or select an existing project
3. Follow the setup wizard

### Step 2: Add Android App
1. In Firebase Console, go to Project Settings (gear icon)
2. Scroll to "Your apps" section
3. Click "Add app" and select Android
4. Enter package name: `com.example.coursehub`
5. Download `google-services.json`
6. Place it in `android/app/google-services.json` (replace the template file)

### Step 3: Add iOS App
1. In Firebase Console, go to Project Settings
2. Click "Add app" and select iOS
3. **Important:** Enter bundle ID: `co.zw.coursehub` (NOT `com.example.coursehub`)
   - The actual bundle ID in the iOS project is `co.zw.coursehub`
   - Make sure to use this exact bundle ID in Firebase Console
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/GoogleService-Info.plist` (replace the template file)

### Step 4: Update firebase_options.dart
1. In Firebase Console, go to Project Settings
2. Scroll to "Your apps" section
3. For each platform (Web, Android, iOS), copy the configuration values
4. Update `lib/firebase_options.dart` with the actual values:
   - `apiKey`: Your API key
   - `appId`: Your App ID
   - `messagingSenderId`: Your Sender ID
   - `projectId`: Your Project ID
   - `authDomain`: Your Auth Domain (for web)
   - `storageBucket`: Your Storage Bucket

---

## Enable Firebase Services

### 1. Enable Authentication
1. Go to Firebase Console > Authentication
2. Click "Get started" if not already enabled
3. Go to "Sign-in method" tab
4. Enable "Email/Password"
5. Enable "Google" sign-in:
   - For Android: Add your SHA-1 fingerprint
     - Get SHA-1: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
     - Or: `cd android && ./gradlew signingReport`
   - For iOS: No additional setup needed

### 2. Create Firestore Database
1. Go to Firebase Console > Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database
5. Click "Enable"

### 3. Set Up Firestore Security Rules (Important!)
Replace the default rules with these basic rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Posts: authenticated users can read, only creators can write
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    
    // Events: authenticated users can read, only creators can write
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.creatorId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.creatorId == request.auth.uid;
      allow update: if request.auth != null && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['attendees']);
    }
  }
}
```

**⚠️ Security Note:** The test mode rules allow all reads/writes. Update these rules before deploying to production!

---

## Verify Configuration

### Check Android Configuration
- ✅ `android/app/google-services.json` exists and contains real values
- ✅ `android/build.gradle.kts` includes Google Services classpath
- ✅ `android/app/build.gradle.kts` applies Google Services plugin
- ✅ `android/app/src/main/AndroidManifest.xml` has INTERNET permission

### Check iOS Configuration
- ✅ `ios/Runner/GoogleService-Info.plist` exists and contains real values
- ✅ Xcode project is configured (usually automatic)

### Check Flutter Configuration
- ✅ `lib/firebase_options.dart` has real values (not placeholders)
- ✅ `lib/main.dart` initializes Firebase
- ✅ Dependencies in `pubspec.yaml` are installed

---

## Test the Setup

1. Run the app:
   ```bash
   flutter run
   ```

2. Test authentication:
   - Try signing up with email/password
   - Try signing in with Google
   - Check Firebase Console > Authentication to see if users are created

3. Test Firestore:
   - Create a post in the forum
   - Check Firebase Console > Firestore Database to see if data is saved

---

## Current Status
- ✅ Firebase dependencies added (`firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`)
- ✅ Google Services plugin configured for Android
- ✅ Internet permission added to AndroidManifest
- ✅ Authentication service implemented
- ✅ Firestore service implemented
- ✅ Firebase initialization in `main.dart`
- ⚠️ **Action Required:** Add your Firebase project configuration files
  - `android/app/google-services.json` (download from Firebase Console)
  - `ios/Runner/GoogleService-Info.plist` (download from Firebase Console)
  - Update `lib/firebase_options.dart` with real values

---

## Troubleshooting

### Android Issues
- **Build Error:** Make sure `google-services.json` is in `android/app/` directory
- **Google Sign-In not working:** Add SHA-1 fingerprint to Firebase Console
- **Network error:** Check INTERNET permission in AndroidManifest.xml

### iOS Issues
- **Build Error:** Make sure `GoogleService-Info.plist` is in `ios/Runner/` directory
- **Google Sign-In not working:** Check bundle ID matches Firebase Console
- **CocoaPods issues:** Run `cd ios && pod install`

### General Issues
- **Firebase not initializing:** Check `firebase_options.dart` has real values
- **Authentication errors:** Verify Authentication is enabled in Firebase Console
- **Firestore errors:** Verify Firestore database is created and rules are set

---

## Next Steps After Setup
1. ✅ Configure Firebase (follow steps above)
2. Test authentication on device/emulator
3. Set up proper Firestore security rules for production
4. Configure Firebase Storage if needed for file uploads
5. Set up Firebase Cloud Messaging for push notifications (optional)