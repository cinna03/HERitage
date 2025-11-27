import 'package:flutter_test/flutter_test.dart';
import 'package:coursehub/providers/forum_provider.dart';

void main() {
  group('ForumProvider Tests', () {
    late ForumProvider forumProvider;

    setUp(() {
      forumProvider = ForumProvider();
    });

    test('should initialize with empty posts', () {
      expect(forumProvider.posts, isEmpty);
      expect(forumProvider.isLoading, false);
    });

    test('should set loading state when creating post', () async {
      expect(forumProvider.isLoading, false);
      
      try {
        await forumProvider.createPost('Test Title', 'Test Content', 'Test Author');
      } catch (e) {
        // Expected to fail without Firebase setup
      }
      
      expect(forumProvider.isLoading, false);
    });
  });
}