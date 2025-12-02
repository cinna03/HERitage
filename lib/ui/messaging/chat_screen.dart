import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coursehub/utils/index.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../utils/error_handler.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserProfilePicture;
  final Map<String, dynamic>? sharePostData; // Optional post data to share

  ChatScreen({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserProfilePicture,
    this.sharePostData,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _scrollToBottom();
      // If sharing a post, send it automatically
      if (widget.sharePostData != null) {
        await _sharePostAutomatically();
      }
    });
  }

  Future<void> _sharePostAutomatically() async {
    if (widget.sharePostData == null) return;
    
    final title = widget.sharePostData!['title'] as String? ?? '';
    final content = widget.sharePostData!['content'] as String? ?? '';
    final author = widget.sharePostData!['author'] as String? ?? '';
    
    final shareText = '📢 Shared Post: $title\n\n$content\n\n- Shared by $author';
    
    try {
      await _firestoreService.sendDirectMessage(
        widget.conversationId,
        {
          'text': shareText,
          'senderId': _auth.currentUser?.uid ?? '',
          'senderName': _auth.currentUser?.displayName ?? _auth.currentUser?.email?.split('@')[0] ?? 'You',
          'timestamp': FieldValue.serverTimestamp(),
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silently fail - user can manually share if needed
      print('Failed to auto-share post: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) {
      ErrorHandler.showError(context, 'You must be logged in to send messages');
      return;
    }

    try {
      await _firestoreService.sendDirectMessage(
        widget.conversationId,
        {
          'text': _messageController.text.trim(),
          'senderId': user.uid,
          'senderName': user.displayName ?? user.email?.split('@')[0] ?? 'You',
          'timestamp': FieldValue.serverTimestamp(),
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      _messageController.clear();
      
      // Scroll to bottom after sending
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    } catch (e) {
      ErrorHandler.showError(context, 'Failed to send message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: white,
              backgroundImage: widget.otherUserProfilePicture != null &&
                      widget.otherUserProfilePicture!.isNotEmpty
                  ? NetworkImage(widget.otherUserProfilePicture!)
                  : null,
              child: widget.otherUserProfilePicture == null ||
                      widget.otherUserProfilePicture!.isEmpty
                  ? Icon(Icons.person, color: primaryPink, size: 18)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: primaryPink,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getDirectMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryPink));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading messages: ${snapshot.error}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: mediumGrey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: mediumGrey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                // Auto-scroll when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    final senderId = messageData['senderId'] as String?;
                    final isMe = senderId == currentUserId;
                    final text = messageData['text'] as String? ?? '';
                    final timestamp = messageData['timestamp'];

                    return _buildMessageBubble(
                      text,
                      isMe,
                      timestamp,
                      theme,
                      isDark,
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: theme.textTheme.bodyMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: lightPink),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: primaryPink, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: primaryPink,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: Icon(Icons.send, color: white),
                      constraints: BoxConstraints(minWidth: 48, minHeight: 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    String text,
    bool isMe,
    dynamic timestamp,
    ThemeData theme,
    bool isDark,
  ) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? primaryPink : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: isMe ? Radius.circular(20) : Radius.circular(0),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? white : theme.textTheme.bodyLarge?.color,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                color: isMe
                    ? white.withValues(alpha: 0.7)
                    : mediumGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
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
      if (difference.inHours < 1) return '${difference.inMinutes}m ago';
      if (difference.inDays < 1) return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    return timestamp.toString();
  }
}

