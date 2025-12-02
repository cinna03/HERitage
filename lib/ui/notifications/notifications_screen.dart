import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursehub/utils/index.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/error_handler.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
          backgroundColor: primaryPink,
        ),
        body: Center(
          child: Text('Please log in to view notifications'),
        ),
      );
    }
    
    final firestoreService = FirestoreService();
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: primaryPink,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getUserNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryPink),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: errorRed),
                  SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: mediumGrey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: mediumGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'ll see notifications here when people interact with your posts',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: mediumGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          final notifications = snapshot.data!.docs;
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notificationData = notifications[index].data() as Map<String, dynamic>;
              final type = notificationData['type'] as String? ?? 'unknown';
              final fromUserName = notificationData['fromUserName'] as String? ?? 'Someone';
              final postTitle = notificationData['postTitle'] as String? ?? 'Post';
              final timestamp = notificationData['timestamp'];
              final read = notificationData['read'] as bool? ?? false;
              final commentText = notificationData['commentText'] as String?;
              
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: read 
                      ? theme.cardColor.withValues(alpha: 0.5)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: read 
                        ? Colors.transparent
                        : primaryPink.withValues(alpha: 0.3),
                    width: read ? 0 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getNotificationColor(type).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getNotificationIcon(type),
                        color: _getNotificationColor(type),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getNotificationMessage(type, fromUserName, postTitle, commentText),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: read ? FontWeight.normal : FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatTimestamp(timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: mediumGrey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!read)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryPink,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'share':
        return Icons.share;
      default:
        return Icons.notifications;
    }
  }
  
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'like':
        return errorRed;
      case 'comment':
        return primaryPink;
      case 'share':
        return successGreen;
      default:
        return mediumGrey;
    }
  }
  
  String _getNotificationMessage(String type, String fromUserName, String postTitle, String? commentText) {
    switch (type) {
      case 'like':
        return '$fromUserName liked your post "$postTitle"';
      case 'comment':
        return '$fromUserName commented on your post "$postTitle"${commentText != null ? ': "$commentText"' : ''}';
      case 'share':
        return '$fromUserName shared your post "$postTitle"';
      default:
        return 'New notification';
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
    return timestamp.toString();
  }
}

