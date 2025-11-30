import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import '../../models/chat_room.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  ChatRoomScreen({required this.chatRoom});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [
    ChatMessage('Sarah M.', 'Hey everyone! Just joined this room 👋', '10:30 AM', false),
    ChatMessage('Amina K.', 'Welcome Sarah! We\'re glad to have you here', '10:32 AM', false),
    ChatMessage('Grace O.', 'I just uploaded my latest painting to the gallery. Would love some feedback!', '10:45 AM', false),
    ChatMessage('You', 'That sounds amazing Grace! Can\'t wait to see it', '10:47 AM', true),
    ChatMessage('Fatima A.', 'Has anyone tried the new brush techniques from yesterday\'s workshop?', '11:15 AM', false),
    ChatMessage('Sarah M.', 'Yes! They\'re game-changing. My blending has improved so much', '11:18 AM', false),
  ];

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
              style: TextStyle(fontSize: 12, color: white.withOpacity(0.8)),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isMe;
    
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
                    color: lightPink.withOpacity(0.3),
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
                      message.sender,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryPink,
                      ),
                    ),
                  if (!isMe) SizedBox(height: 4),
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? white : darkGrey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message.timestamp,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? white.withOpacity(0.7) : mediumGrey,
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

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: lightPink.withOpacity(0.3),
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
                onSubmitted: (_) => _sendMessage(),
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
              child: IconButton(
                onPressed: _sendMessage,
                icon: Icon(Icons.send, color: white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add(
          ChatMessage(
            'You',
            _messageController.text.trim(),
            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
            true,
          ),
        );
        _messageController.clear();
      });
      
      // Scroll to bottom
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
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