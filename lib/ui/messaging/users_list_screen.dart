import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursehub/utils/index.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import 'chat_screen.dart';

class UsersListScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'All Users',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: primaryPink,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uid', isNotEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryPink));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: errorRed),
                  SizedBox(height: 16),
                  Text('Error loading users'),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'),
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
                  Icon(Icons.people_outline, size: 64, color: mediumGrey),
                  SizedBox(height: 16),
                  Text(
                    'No other users found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: mediumGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = userData['uid'] as String;
              final username = userData['username'] as String? ?? 'Unknown';
              final email = userData['email'] as String? ?? '';
              final profilePictureUrl = userData['profilePictureUrl'] as String?;

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: primaryPink,
                    backgroundImage: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                        ? NetworkImage(profilePictureUrl)
                        : null,
                    child: profilePictureUrl == null || profilePictureUrl.isEmpty
                        ? Icon(Icons.person, color: white)
                        : null,
                  ),
                  title: Text(
                    username,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: email.isNotEmpty
                      ? Text(
                          email,
                          style: theme.textTheme.bodySmall,
                        )
                      : null,
                  trailing: ElevatedButton(
                    onPressed: () async {
                      if (currentUserId == null) return;

                      try {
                        final conversationId = await _firestoreService.getOrCreateConversation(
                          currentUserId,
                          userId,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              conversationId: conversationId,
                              otherUserId: userId,
                              otherUserName: username,
                              otherUserProfilePicture: profilePictureUrl,
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to start chat: $e'),
                            backgroundColor: errorRed,
                          ),
                        );
                      }
                    },
                    child: Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

