import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  const MethodChannel('plugins.flutter.io/firebase_core')
      .setMockMethodCallHandler((methodCall) async {
    if (methodCall.method == 'Firebase#initializeCore') {
      return [
        {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': 'fake-api-key',
            'appId': 'fake-app-id',
            'messagingSenderId': 'fake-sender-id',
            'projectId': 'fake-project-id',
          },
          'pluginConstants': {},
        }
      ];
    }
    return null;
  });

  const MethodChannel('plugins.flutter.io/firebase_auth')
      .setMockMethodCallHandler((methodCall) async {
    return null;
  });
}