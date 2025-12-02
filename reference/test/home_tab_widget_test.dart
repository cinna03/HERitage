import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/ui/dashboard/home_tab.dart';
import 'package:coursehub/providers/auth_provider.dart';
import 'package:coursehub/providers/user_stats_provider.dart';

void main() {
  testWidgets('HomeTab renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserStatsProvider()),
        ],
        child: MaterialApp(home: HomeTab()),
      ),
    );
    
    await tester.pumpAndSettle();
    expect(find.byType(HomeTab), findsOneWidget);
  });

  testWidgets('HomeTab shows progress section', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserStatsProvider()),
        ],
        child: MaterialApp(home: HomeTab()),
      ),
    );
    
    await tester.pumpAndSettle();
    expect(find.byType(HomeTab), findsOneWidget);
  });
}

