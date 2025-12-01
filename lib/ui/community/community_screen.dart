import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursehub/utils/index.dart';
import '../../utils/error_handler.dart';
import '../../widgets/loading_overlay.dart';
import '../../models/chat_room.dart';
import 'chat_room_screen.dart';
import 'mentors_screen.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

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
          unselectedLabelColor: white.withValues(alpha: 0.7),
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
    return Consumer<ForumProvider>(
      builder: (context, forumProvider, child) {
        if (forumProvider.isLoading && forumProvider.posts.isEmpty) {
          return LoadingIndicator(message: 'Loading posts...');
        }

        if (forumProvider.error != null && forumProvider.posts.isEmpty) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Error loading posts',
            message: forumProvider.error,
            action: ElevatedButton(
              onPressed: () {
                // Retry loading
              },
              child: Text('Retry'),
            ),
          );
        }

        if (forumProvider.posts.isEmpty) {
          return EmptyState(
            icon: Icons.forum,
            title: 'No posts yet',
            message: 'Be the first to start a discussion!',
          );
        }

        return Container(
          color: Color(0xFFF8F8F8),
          child: ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: forumProvider.posts.length,
            itemBuilder: (context, index) {
              final post = forumProvider.posts[index];
              return _buildForumPostCardFromMap(post);
            },
          ),
        );
      },
    );
  }



  Widget _buildForumPostCardFromMap(Map<String, dynamic> post) {
    final author = post['author'] ?? 'Anonymous';
    final title = post['title'] ?? '';
    final content = post['content'] ?? '';
    final timestamp = _formatTimestamp(post['timestamp']);
    final likes = post['likes'] ?? 0;
    final comments = post['comments'] ?? 0;
    final postId = post['id'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: lightPink.withValues(alpha: 0.3),
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
                      author,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                    Text(
                      timestamp,
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
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkGrey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: mediumGrey,
              height: 1.4,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Consumer<ForumProvider>(
                builder: (context, forumProvider, child) {
                  return InkWell(
                    onTap: () => forumProvider.likePost(postId),
                    child: Row(
                      children: [
                        Icon(Icons.favorite_border, size: 20, color: primaryPink),
                        SizedBox(width: 4),
                        Text(
                          '$likes',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryPink,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(width: 20),
              _buildInteractionButton(Icons.comment_outlined, '$comments', mediumGrey),
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    if (timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    return 'Just now';
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
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading && chatProvider.chatRooms.isEmpty) {
          return LoadingIndicator(message: 'Loading chat rooms...');
        }

        if (chatProvider.error != null && chatProvider.chatRooms.isEmpty) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Error loading chat rooms',
            message: chatProvider.error,
          );
        }

        if (chatProvider.chatRooms.isEmpty) {
          return EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'No chat rooms yet',
            message: 'Create a chat room to start connecting!',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(20),
          itemCount: chatProvider.chatRooms.length,
          itemBuilder: (context, index) {
            final roomData = chatProvider.chatRooms[index];
            final room = ChatRoom(
              roomData['name'] ?? 'Unnamed Room',
              roomData['description'] ?? '',
              (roomData['memberCount'] ?? 0) as int,
              roomData['isActive'] ?? false,
            );
            return _buildChatRoomCard(room, roomData['id'] as String?);
          },
        );
      },
    );
  }

  Widget _buildChatRoomCard(ChatRoom room, String? roomId) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: lightPink.withValues(alpha: 0.3),
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
            color: primaryPink.withValues(alpha: 0.1),
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
              builder: (context) => ChatRoomScreen(
                chatRoom: room,
                chatRoomId: roomId,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreatePostDialog() {
    _titleController.clear();
    _contentController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _contentController,
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
            onPressed: () async {
              if (_titleController.text.trim().isNotEmpty && 
                  _contentController.text.trim().isNotEmpty) {
                final forumProvider = Provider.of<ForumProvider>(context, listen: false);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                
                try {
                  final author = authProvider.userEmail?.split('@')[0] ?? 
                                 authProvider.user?.displayName ?? 
                                 'Anonymous';
                  
                  await forumProvider.createPost(
                    _titleController.text.trim(),
                    _contentController.text.trim(),
                    author,
                  );
                  
                  _titleController.clear();
                  _contentController.clear();
                  _titleController.clear();
                  _contentController.clear();
                  Navigator.pop(context);
                  ErrorHandler.showSuccess(context, 'Post created successfully!');
                } catch (e) {
                  ErrorHandler.showError(context, e);
                }
              }
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

