import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import '../../utils/error_handler.dart';
import '../../widgets/loading_overlay.dart';
import '../../services/firestore_service.dart';
import 'post_comments_screen.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../messaging/messaging_screen.dart';
import '../messaging/chat_screen.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    
    // Ensure forum provider refreshes when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      forumProvider.refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.of(context).canPop() ? Navigator.pop(context) : null,
        ),
        title: Text(
          'Community Forums',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: primaryPink,
        elevation: 0,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: white,
                ),
                tooltip: 'Toggle theme',
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: _buildSearchBar(),
        ),
      ),
      body: _buildForumsTab(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog();
        },
        backgroundColor: primaryPink,
        child: Icon(Icons.add, color: white),
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: primaryPink,
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: white),
        decoration: InputDecoration(
          hintText: 'Search posts...',
          hintStyle: TextStyle(color: white.withValues(alpha: 0.7)),
          prefixIcon: Icon(Icons.search, color: white),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: white),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: white.withValues(alpha: 0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: errorRed),
                SizedBox(height: 16),
                Text(
                  'Error loading posts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    forumProvider.error ?? 'Unknown error',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    forumProvider.refresh();
                  },
                  child: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                  ),
                ),
              ],
            ),
          );
        }

        // Filter posts based on search query
        final filteredPosts = _searchQuery.isEmpty
            ? forumProvider.posts
            : forumProvider.posts.where((post) {
                final title = (post['title'] ?? '').toString().toLowerCase();
                final content = (post['content'] ?? '').toString().toLowerCase();
                final author = (post['author'] ?? '').toString().toLowerCase();
                return title.contains(_searchQuery) ||
                    content.contains(_searchQuery) ||
                    author.contains(_searchQuery);
              }).toList();

        if (filteredPosts.isEmpty) {
          return EmptyState(
            icon: _searchQuery.isNotEmpty ? Icons.search_off : Icons.forum,
            title: _searchQuery.isNotEmpty ? 'No posts found' : 'No posts yet',
            message: _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Be the first to start a discussion!',
          );
        }

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index];
              return _buildForumPostCardFromMap(post);
            },
          ),
        );
      },
    );
  }



  Widget _buildForumPostCardFromMap(Map<String, dynamic> post) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timestamp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: mediumGrey),
                itemBuilder: (context) => [
                  PopupMenuItem(child: Text('Chat'), value: 'chat'),
                  PopupMenuItem(child: Text('Report'), value: 'report'),
                  PopupMenuItem(child: Text('Share'), value: 'share'),
                ],
                onSelected: (value) => _handlePostMenuAction(value, post),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Consumer<ForumProvider>(
                builder: (context, forumProvider, child) {
                  final isLiked = forumProvider.isPostLiked(postId);
                  return InkWell(
                    onTap: () => forumProvider.toggleLikePost(postId),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isLiked ? primaryPink : primaryPink.withValues(alpha: 0.6),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '$likes',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLiked ? primaryPink : primaryPink.withValues(alpha: 0.6),
                            fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(width: 20),
              StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getPostComments(postId),
                builder: (context, snapshot) {
                  // Get actual comment count from comments subcollection
                  final commentCount = snapshot.hasData ? snapshot.data!.docs.length : comments;
                  
                  return InkWell(
                    onTap: () => _showComments(postId, title, author),
                    child: Row(
                      children: [
                        Icon(Icons.comment_outlined, size: 20, color: theme.iconTheme.color?.withValues(alpha: 0.6) ?? mediumGrey),
                        SizedBox(width: 4),
                        Text(
                          '$commentCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.iconTheme.color?.withValues(alpha: 0.6) ?? mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(width: 20),
              InkWell(
                onTap: () => _sharePost(postId, title, content, author),
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 20, color: theme.iconTheme.color?.withValues(alpha: 0.6) ?? mediumGrey),
                    SizedBox(width: 4),
                    Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.iconTheme.color?.withValues(alpha: 0.6) ?? mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () => _showComments(postId, title, author),
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


  void _showComments(String postId, String postTitle, String postAuthor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: mediumGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(),
            // Comments content
            Expanded(
              child: PostCommentsScreen(
                postId: postId,
                postTitle: postTitle,
                postAuthor: postAuthor,
                isBottomSheet: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(String postId, String title, String content, String author) {
    // Navigate to messaging screen to share post with users
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagingScreen(sharePostData: {
          'postId': postId,
          'title': title,
          'content': content,
          'author': author,
        }),
      ),
    );
  }

  void _handlePostMenuAction(String action, Map<String, dynamic> post) async {
    switch (action) {
      case 'chat':
        await _startChatWithUser(post);
        break;
      case 'report':
        // Handle report action
        break;
      case 'share':
        _sharePost(post['id'] ?? '', post['title'] ?? '', post['content'] ?? '', post['author'] ?? '');
        break;
    }
  }

  Future<void> _startChatWithUser(Map<String, dynamic> post) async {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    
    if (currentUser == null) {
      ErrorHandler.showError(context, 'You must be logged in to start a chat');
      return;
    }

    // Try to get userId, fallback to finding user by author name
    String? postUserId = post['userId'] as String?;
    final postAuthor = post['author'] as String? ?? 'Unknown User';
    
    // If no userId, try to find user by author name
    if (postUserId == null || postUserId.isEmpty) {
      try {
        final usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('displayName', isEqualTo: postAuthor)
            .limit(1)
            .get();
        
        if (usersSnapshot.docs.isNotEmpty) {
          postUserId = usersSnapshot.docs.first.id;
        }
      } catch (e) {
        // Ignore error, will show message below
      }
    }
    
    if (postUserId == null || postUserId.isEmpty) {
      ErrorHandler.showError(context, 'Cannot start chat: User information not available');
      return;
    }

    if (postUserId == currentUser.uid) {
      ErrorHandler.showError(context, 'You cannot chat with yourself');
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: primaryPink),
        ),
      );

      // Create or get conversation
      final conversationId = await _firestoreService.getOrCreateConversation(
        currentUser.uid,
        postUserId,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            conversationId: conversationId,
            otherUserId: postUserId!,
            otherUserName: postAuthor,
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ErrorHandler.showError(context, 'Failed to start chat: $e');
    }
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
                final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
                
                try {
                  final author = authProvider.userEmail?.split('@')[0] ?? 
                                 authProvider.user?.displayName ?? 
                                 'Anonymous';
                  
                  // Close dialog first
                  Navigator.pop(context);
                  
                  // Create post
                  await forumProvider.createPost(
                    _titleController.text.trim(),
                    _contentController.text.trim(),
                    author,
                  );
                  
                  // Clear controllers
                  _titleController.clear();
                  _contentController.clear();
                  
                  // Show success message
                  ErrorHandler.showSuccess(context, 'Post created successfully!');
                  
                  // Scroll to top to show new post (it will be at the top)
                  // The real-time stream will automatically update the list
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

