import 'package:flutter_test/flutter_test.dart';
import 'package:coursehub/providers/event_provider.dart';

void main() {
  group('EventProvider Tests', () {
    late EventProvider eventProvider;

    setUp(() {
      eventProvider = EventProvider();
    });

    test('should initialize with empty events', () {
      expect(eventProvider.events, isEmpty);
      expect(eventProvider.isLoading, false);
      expect(eventProvider.error, isNull);
      expect(eventProvider.currentEvent, isNull);
    });
  });
}





