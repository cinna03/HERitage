import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import '../../models/chat_room.dart';
import 'chat_room_screen.dart';
import 'mentors_screen.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('Community', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryPink,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: white,
          labelColor: white,
          unselectedLabelColor: white.withOpacity(0.7),
          tabs: [
            Tab(text: 'Forums'),
            Tab(text: 'Chat Rooms'),
            Tab(text: 'Mentors'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForumsTab(),
          _buildChatRoomsTab(),
          MentorsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog();
        },
        backgroundColor: primaryPink,
        child: Icon(Icons.add, color: white),
      ),
    );
  }

  Widget _buildForumsTab() {
    return Container(
      color: Color(0xFFF8F8F8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChatBubble(
              'Hey everyone! Just finished my first digital painting. What do you think?',
              true,
            ),
            SizedBox(height: 20),
            _buildChatBubble(
              'That looks amazing! I love the color choices. Keep up the great work!',
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 40),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isUser ? lightPink : Color(0xFF4A4A4A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
            bottomLeft: isUser ? Radius.circular(25) : Radius.circular(5),
            bottomRight: isUser ? Radius.circular(5) : Radius.circular(25),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? darkGrey : white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildForumPostCard(ForumPost post) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: lightPink.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryPink,
                child: Icon(Icons.person, color: white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                    Text(
                      post.timestamp,
                      style: TextStyle(
                        fontSize: 12,
                        color: mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: mediumGrey),
                itemBuilder: (context) => [
                  PopupMenuItem(child: Text('Report'), value: 'report'),
                  PopupMenuItem(child: Text('Share'), value: 'share'),
                ],
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            post.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkGrey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            post.content,
            style: TextStyle(
              fontSize: 14,
              color: mediumGrey,
              height: 1.4,
            ),
          ),
          if (post.imageUrl != null) ...[
            SizedBox(height: 15),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(Icons.image, size: 40, color: mediumGrey),
              ),
            ),
          ],
          SizedBox(height: 15),
          Row(
            children: [
              _buildInteractionButton(Icons.favorite_border, '${post.likes}', primaryPink),
              SizedBox(width: 20),
              _buildInteractionButton(Icons.comment_outlined, '${post.comments}', mediumGrey),
              SizedBox(width: 20),
              _buildInteractionButton(Icons.share_outlined, 'Share', mediumGrey),
              Spacer(),
              TextButton(
                onPressed: () {},
                child: Text('View Comments', style: TextStyle(color: primaryPink)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomsTab() {
    final chatRooms = [
      ChatRoom('Digital Art Beginners', 'Share your first creations and get feedback', 45, true),
      ChatRoom('Music Production Hub', 'Collaborate and share beats', 32, false),
      ChatRoom('Photography Tips', 'Daily challenges and critiques', 67, true),
      ChatRoom('Design Inspiration', 'Mood boards and creative ideas', 28, false),
      ChatRoom('Freelance Success', 'Business tips and client stories', 89, true),
      ChatRoom('African Art Heritage', 'Celebrating our cultural roots', 156, false),
    ];

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: chatRooms.length,
      itemBuilder: (context, index) {
        return _buildChatRoomCard(chatRooms[index]);
      },
    );
  }

  Widget _buildChatRoomCard(ChatRoom room) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: lightPink.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: primaryPink.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.chat, color: primaryPink),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                room.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
            ),
            if (room.isActive)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: successGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              room.description,
              style: TextStyle(
                fontSize: 14,
                color: mediumGrey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${room.memberCount} members',
              style: TextStyle(
                fontSize: 12,
                color: primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: primaryPink),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(chatRoom: room),
            ),
          );
        },
      ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Post created successfully!')),
              );
            },
            child: Text('Post'),
          ),
        ],
      ),
    );
  }
}

class ForumPost {
  final String author;
  final String title;
  final String content;
  final String timestamp;
  final int likes;
  final int comments;
  final String? imageUrl;

  ForumPost(this.author, this.title, this.content, this.timestamp, 
           this.likes, this.comments, this.imageUrl);
}

