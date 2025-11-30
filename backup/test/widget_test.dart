// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coursehub/main.dart';
import 'package:coursehub/ui/auth/login_screen.dart';
import 'test_helper.dart';

void main() {
  setUpAll(() {
    setupFirebaseAuthMocks();
  });

  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Login button is tappable', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButton, findsOneWidget);
    
    await tester.tap(loginButton);
    await tester.pump();
  });

  testWidgets('Google sign-in button exists', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
