import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontFamily: 'Lato'),
        ),
        backgroundColor: primaryPink,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return notificationProvider.unreadCount > 0
                  ? TextButton(
                      onPressed: () {
                        notificationProvider.markAllAsRead();
                      },
                      child: Text(
                        'Mark All Read',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: primaryPink));
          }

          if (notificationProvider.notifications.isEmpty) {
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
                    'You\'ll see notifications for posts, messages, and events here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: mediumGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return _buildNotificationCard(notification, theme, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    ThemeData theme,
    bool isDark,
  ) {
    final isRead = notification['read'] ?? false;
    final type = notification['type'] ?? 'general';
    final title = _getNotificationTitle(notification);
    final body = _getNotificationBody(notification);
    final timestamp = _formatTimestamp(notification['createdAt']);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead 
            ? theme.cardColor 
            : primaryPink.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: isRead 
            ? null 
            : Border.all(color: primaryPink.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getNotificationColor(type).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getNotificationIcon(type),
            color: _getNotificationColor(type),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isRead ? mediumGrey : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              timestamp,
              style: theme.textTheme.bodySmall?.copyWith(
                color: mediumGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: !isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: primaryPink,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          if (!isRead) {
            Provider.of<NotificationProvider>(context, listen: false)
                .markAsRead(notification['id']);
          }
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  String _getNotificationTitle(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'general';
    final fromUserName = notification['fromUserName'] ?? 'Someone';
    
    switch (type) {
      case 'like':
        return '$fromUserName liked your post';
      case 'comment':
        return '$fromUserName commented on your post';
      case 'message':
        return 'New message from $fromUserName';
      case 'event':
        return 'Event reminder';
      default:
        return notification['title'] ?? 'Notification';
    }
  }

  String _getNotificationBody(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'general';
    
    switch (type) {
      case 'like':
        return notification['postTitle'] ?? 'Your post';
      case 'comment':
        return notification['commentText'] ?? 'New comment on your post';
      case 'message':
        return notification['messageText'] ?? 'You have a new message';
      case 'event':
        return notification['body'] ?? 'You have an upcoming event';
      default:
        return notification['body'] ?? 'You have a new notification';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'message':
        return Icons.message;
      case 'event':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'message':
        return primaryPink;
      case 'event':
        return Colors.orange;
      default:
        return primaryPink;
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Just now';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inHours < 1) return '${difference.inMinutes}m ago';
      if (difference.inDays < 1) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Just now';
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'general';
    
    switch (type) {
      case 'like':
      case 'comment':
        // Navigate to post details
        break;
      case 'message':
        // Navigate to chat
        break;
      case 'event':
        // Navigate to calendar or event details
        break;
      default:
        break;
    }
  }
}