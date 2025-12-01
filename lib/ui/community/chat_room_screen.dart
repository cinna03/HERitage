import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coursehub/utils/index.dart';
import '../../utils/error_handler.dart';
import '../../widgets/loading_overlay.dart';
import '../../models/chat_room.dart';
import '../../providers/chat_provider.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  final String? chatRoomId; // Firestore document ID

  ChatRoomScreen({required this.chatRoom, this.chatRoomId});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _roomId;

  @override
  void initState() {
    super.initState();
    _roomId = widget.chatRoomId ?? 'default-room';
    // Load messages when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.loadMessages(_roomId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.clearMessages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chatRoom.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.chatRoom.memberCount} members',
              style: TextStyle(fontSize: 12, color: white.withValues(alpha: 0.8)),
            ),
          ],
        ),
        backgroundColor: primaryPink,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showRoomInfo(),
            icon: Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading && chatProvider.messages.isEmpty) {
            return LoadingIndicator(message: 'Loading messages...');
          }

          if (chatProvider.error != null && chatProvider.messages.isEmpty) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Error loading messages',
              message: chatProvider.error,
              action: ElevatedButton(
                onPressed: () {
                  chatProvider.loadMessages(_roomId);
                },
                child: Text('Retry'),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(15),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return _buildMessageBubbleFromMap(message);
                  },
                ),
              ),
              _buildMessageInput(chatProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubbleFromMap(Map<String, dynamic> message) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final senderId = message['senderId'] as String?;
    final isMe = currentUser != null && senderId == currentUser.uid;
    final senderName = message['senderName'] ?? 'Anonymous';
    final text = message['text'] ?? '';
    final timestamp = _formatTimestamp(message['timestamp']);

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: primaryPink,
              child: Icon(Icons.person, color: white, size: 16),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? primaryPink : white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: isMe ? Radius.circular(15) : Radius.circular(5),
                  bottomRight: isMe ? Radius.circular(5) : Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: lightPink.withValues(alpha: 0.3),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryPink,
                      ),
                    ),
                  if (!isMe) SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? white : darkGrey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? white.withValues(alpha: 0.7) : mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: accentPink,
              child: Icon(Icons.person, color: white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    if (timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      
      // Format time
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    }
    return 'Just now';
  }


  Widget _buildMessageInput(ChatProvider chatProvider) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: lightPink.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                // Add attachment
              },
              icon: Icon(Icons.attach_file, color: primaryPink),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(chatProvider),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: lightPink),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: primaryPink),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                maxLines: null,
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: primaryPink,
                shape: BoxShape.circle,
              ),
              child: chatProvider.isLoading
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(white),
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () => _sendMessage(chatProvider),
                      icon: Icon(Icons.send, color: white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(ChatProvider chatProvider) async {
    if (_messageController.text.trim().isNotEmpty) {
      try {
        await chatProvider.sendMessage(_roomId, _messageController.text.trim());
        _messageController.clear();
        
        // Scroll to bottom after message is sent
        Future.delayed(Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } catch (e) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  void _showRoomInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.chatRoom.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.chatRoom.description,
                style: TextStyle(
                  fontSize: 14,
                  color: mediumGrey,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.people, color: primaryPink),
                  SizedBox(width: 10),
                  Text('${widget.chatRoom.memberCount} members'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.circle, color: successGreen, size: 12),
                  SizedBox(width: 10),
                  Text('Active now'),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.notifications_off, color: primaryPink),
                      label: Text('Mute', style: TextStyle(color: primaryPink)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryPink),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.exit_to_app, color: errorRed),
                      label: Text('Leave', style: TextStyle(color: errorRed)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: errorRed),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String content;
  final String timestamp;
  final bool isMe;

  ChatMessage(this.sender, this.content, this.timestamp, this.isMe);
}