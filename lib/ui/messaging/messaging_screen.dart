import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursehub/utils/index.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/error_handler.dart';
import 'chat_screen.dart';

class MessagingScreen extends StatefulWidget {
  final Map<String, dynamic>? sharePostData; // Optional post data to share
  
  MessagingScreen({this.sharePostData});
  
  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
    
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Messages'),
          backgroundColor: primaryPink,
        ),
        body: Center(
          child: Text('Please log in to view messages'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: primaryPink,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching) _buildSearchBar(theme),
          Expanded(
            child: _isSearching
                ? _buildUserSearchResults(currentUserId, theme)
                : _buildConversationsList(currentUserId, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16),
      color: theme.cardColor,
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search users by username...',
          prefixIcon: Icon(Icons.search, color: primaryPink),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: lightPink),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: primaryPink, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSearchResults(String currentUserId, ThemeData theme) {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: mediumGrey),
            SizedBox(height: 16),
            Text(
              'Search for users',
              style: theme.textTheme.titleMedium?.copyWith(
                color: mediumGrey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Type a username to find and message users',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mediumGrey,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.searchUsers(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: primaryPink));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: errorRed),
                SizedBox(height: 16),
                Text(
                  'Error loading users',
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
                Icon(Icons.person_off, size: 64, color: mediumGrey),
                SizedBox(height: 16),
                Text(
                  'No users found',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: mediumGrey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Try searching with a different username',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: mediumGrey,
                  ),
                ),
              ],
            ),
          );
        }

        // Filter users in memory: exclude current user and match username (case-insensitive)
        final queryLower = _searchQuery.toLowerCase();
        final users = snapshot.data!.docs.where((doc) {
          final userId = doc.id;
          if (userId == currentUserId) return false; // Exclude current user
          
          final userData = doc.data() as Map<String, dynamic>;
          final username = (userData['username'] ?? '').toString().toLowerCase();
          
          // Case-insensitive search
          return username.contains(queryLower);
        }).toList();

        if (users.isEmpty) {
          return Center(
            child: Text(
              'No other users found',
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final userData = userDoc.data() as Map<String, dynamic>;
            final userId = userDoc.id;
            final username = userData['username'] as String? ?? 'Unknown';
            final email = userData['email'] as String? ?? '';
            final profilePictureUrl = userData['profilePictureUrl'] as String?;

            return _buildUserCard(
              userId,
              username,
              email,
              profilePictureUrl,
              theme,
            );
          },
        );
      },
    );
  }

  Widget _buildUserCard(
    String userId,
    String username,
    String email,
    String? profilePictureUrl,
    ThemeData theme,
  ) {
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
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: mediumGrey),
        onTap: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final currentUserId = authProvider.user?.uid;
          
          if (currentUserId == null) return;

          try {
            // Get or create conversation
            final conversationId = await _firestoreService.getOrCreateConversation(
              currentUserId,
              userId,
            );

            // Navigate to chat screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  conversationId: conversationId,
                  otherUserId: userId,
                  otherUserName: username,
                  otherUserProfilePicture: profilePictureUrl,
                  sharePostData: widget.sharePostData,
                ),
              ),
            );
          } catch (e) {
            ErrorHandler.showError(context, 'Failed to start conversation: $e');
          }
        },
      ),
    );
  }

  Widget _buildConversationsList(String currentUserId, ThemeData theme) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getUserConversations(currentUserId),
      builder: (context, snapshot) {
        // Show loading only for initial load, not for subsequent updates
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: primaryPink));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: errorRed),
                SizedBox(height: 16),
                Text(
                  'Error loading conversations',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    snapshot.error.toString(),
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Retry by rebuilding
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

        // Check if we have data or if it's empty
        final hasData = snapshot.hasData;
        final isEmpty = hasData && snapshot.data!.docs.isEmpty;

        if (!hasData || isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: mediumGrey),
                SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: mediumGrey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the search icon to find users and start a conversation',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: mediumGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  icon: Icon(Icons.search),
                  label: Text('Search Users'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                  ),
                ),
              ],
            ),
          );
        }

        final conversations = snapshot.data!.docs;
        
        // Sort conversations by lastMessageTime in memory (in case query ordering fails)
        final sortedConversations = List.from(conversations);
        sortedConversations.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['lastMessageTime'] as Timestamp?;
          final bTime = (b.data() as Map<String, dynamic>)['lastMessageTime'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime); // Descending order
        });

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: sortedConversations.length,
          itemBuilder: (context, index) {
            final conversationData = sortedConversations[index].data() as Map<String, dynamic>;
            final conversationId = sortedConversations[index].id;
            final participants = (conversationData['participants'] as List<dynamic>?) ?? [];
            final otherUserId = participants.firstWhere(
              (id) => id != currentUserId,
              orElse: () => currentUserId,
            ) as String;
            final lastMessage = conversationData['lastMessage'] as String?;
            final lastMessageTime = conversationData['lastMessageTime'] as Timestamp?;

            return FutureBuilder<DocumentSnapshot>(
              future: _firestoreService.getUserProfile(otherUserId),
              builder: (context, userSnapshot) {
                // Show loading placeholder while fetching user profile
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: primaryPink.withValues(alpha: 0.3),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryPink,
                        ),
                      ),
                      title: Container(
                        height: 16,
                        width: 100,
                        color: theme.scaffoldBackgroundColor,
                      ),
                    ),
                  );
                }
                
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return SizedBox.shrink();
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                final username = userData['username'] as String? ?? 'Unknown';
                final profilePictureUrl = userData['profilePictureUrl'] as String?;

                return _buildConversationCard(
                  conversationId,
                  otherUserId,
                  username,
                  profilePictureUrl,
                  lastMessage,
                  lastMessageTime,
                  theme,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildConversationCard(
    String conversationId,
    String otherUserId,
    String otherUserName,
    String? profilePictureUrl,
    String? lastMessage,
    Timestamp? lastMessageTime,
    ThemeData theme,
  ) {
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
          otherUserName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              lastMessage ?? 'No messages yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: lastMessage != null ? null : mediumGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (lastMessageTime != null) ...[
              SizedBox(height: 4),
              Text(
                _formatTimestamp(lastMessageTime),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: mediumGrey,
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: mediumGrey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                conversationId: conversationId,
                otherUserId: otherUserId,
                otherUserName: otherUserName,
                otherUserProfilePicture: profilePictureUrl,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

