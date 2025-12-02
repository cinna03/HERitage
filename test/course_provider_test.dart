import 'package:flutter_test/flutter_test.dart';
import 'package:coursehub/providers/course_provider.dart';

void main() {
  group('CourseProvider Tests', () {
    late CourseProvider courseProvider;

    setUp(() {
      courseProvider = CourseProvider();
    });

    test('should initialize with empty courses', () {
      expect(courseProvider.courses, isEmpty);
      expect(courseProvider.isLoading, false);
      expect(courseProvider.error, isNull);
      expect(courseProvider.currentCourse, isNull);
      expect(courseProvider.userProgress, isNull);
    });
  });
}





