import 'package:flutter_test/flutter_test.dart';
import 'package:coursehub/providers/chat_provider.dart';

void main() {
  group('ChatProvider Tests', () {
    late ChatProvider chatProvider;

    setUp(() {
      chatProvider = ChatProvider();
    });

    test('should initialize with empty chat rooms and messages', () {
      expect(chatProvider.chatRooms, isEmpty);
      expect(chatProvider.messages, isEmpty);
      expect(chatProvider.isLoading, false);
      expect(chatProvider.error, isNull);
    });

    test('should have null currentChatRoomId initially', () {
      expect(chatProvider.currentChatRoomId, isNull);
    });

    test('should clear messages correctly', () {
      chatProvider.clearMessages();
      expect(chatProvider.messages, isEmpty);
      expect(chatProvider.currentChatRoomId, isNull);
    });
  });
}

