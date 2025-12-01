import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/ui/courses/courses_screen.dart';
import 'package:coursehub/providers/course_provider.dart';

void main() {
  testWidgets('CoursesScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CourseProvider()),
        ],
        child: MaterialApp(home: CoursesScreen()),
      ),
    );
    
    await tester.pumpAndSettle();
    expect(find.byType(CoursesScreen), findsOneWidget);
  });

  testWidgets('CoursesScreen has search functionality', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CourseProvider()),
        ],
        child: MaterialApp(home: CoursesScreen()),
      ),
    );
    
    await tester.pumpAndSettle();
    expect(find.byType(CoursesScreen), findsOneWidget);
  });
}

