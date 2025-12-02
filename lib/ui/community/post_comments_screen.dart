import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursehub/utils/index.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/error_handler.dart';

class PostCommentsScreen extends StatefulWidget {
  final String postId;
  final String postTitle;
  final String postAuthor;
  final bool isBottomSheet;

  PostCommentsScreen({
    required this.postId,
    required this.postTitle,
    required this.postAuthor,
    this.isBottomSheet = false,
  });

  @override
  _PostCommentsScreenState createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      ErrorHandler.showError(context, 'Please enter a comment');
      return;
    }

    try {
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      await forumProvider.addComment(widget.postId, _commentController.text.trim());
      _commentController.clear();
      
      // Scroll to bottom to show new comment
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ErrorHandler.showError(context, e);
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    if (timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inHours < 1) return '${difference.inMinutes}m ago';
      if (difference.inDays < 1) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Widget content = Column(
      children: [
        // Post header (only if not bottom sheet)
        if (!widget.isBottomSheet)
          Container(
            padding: EdgeInsets.all(16),
            color: theme.cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.postTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'by ${widget.postAuthor}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        
        // Comments list
        Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getPostComments(widget.postId),
              builder: (context, snapshot) {
                // Show loading only on initial load
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(color: primaryPink));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: errorRed,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading comments',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: errorRed,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: mediumGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Check if there are no comments
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 64,
                            color: mediumGrey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No comments yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: mediumGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'There are no comments under this post at the moment.\nBe the first to comment!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: mediumGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final commentData = comments[index].data() as Map<String, dynamic>;
                    final author = commentData['author'] ?? 'Anonymous';
                    final text = commentData['text'] ?? '';
                    final timestamp = commentData['timestamp'];

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark 
                              ? Colors.grey.withValues(alpha: 0.2)
                              : lightPink,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: primaryPink,
                                child: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      author,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatTimestamp(timestamp),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            text,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
        // Comment input
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
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
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
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: primaryPink,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _addComment,
                    icon: Icon(Icons.send, color: white),
                    constraints: BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.isBottomSheet) {
      return content;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Comments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: primaryPink,
        elevation: 0,
        foregroundColor: white,
      ),
      body: content,
    );
  }
}

