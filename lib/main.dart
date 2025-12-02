import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import 'package:coursehub/ui/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/forum_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/course_provider.dart';
import 'providers/event_provider.dart';
import 'providers/user_stats_provider.dart';
import 'providers/user_profile_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase FIRST
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // CRITICAL: Enable Firestore persistence BEFORE creating any Firestore references
  // This ensures all data (posts, comments, messages) is cached locally and persists
  // across app restarts. Data synced while online is saved to disk, and offline
  // writes are queued and sent when connectivity is restored.
  try {
    await FirebaseFirestore.instance.enablePersistence();
    print('✅ Firestore persistence enabled successfully');
  } catch (e) {
    // Persistence may already be enabled or not supported on this platform
    // On web, persistence uses IndexedDB and is enabled by default
    print('⚠️ Firestore persistence: $e');
  }
  
  // Now run the app - all Firestore references created after this point will use persistence
  runApp(HERmonyApp());
}

class HERmonyApp extends StatefulWidget {
  @override
  _HERmonyAppState createState() => _HERmonyAppState();
}

class _HERmonyAppState extends State<HERmonyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ForumProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserStatsProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'HERmony - Empowering African Women in Arts',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
