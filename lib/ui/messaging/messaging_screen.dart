import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_search_provider.dart';
import '../../utils/error_handler.dart';
import 'chat_screen.dart';
import 'users_list_screen.dart';

class MessagingScreen extends StatefulWidget {
  final Map<String, dynamic>? sharePostData; // Optional post data to share
  
  MessagingScreen({this.sharePostData});
  
  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSearching = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _searchController.addListener(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final searchProvider = Provider.of<UserSearchProvider>(context, listen: false);
      searchProvider.searchUsers(_searchController.text, authProvider.user?.uid ?? '');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
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
          title: Text('Chat'),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.of(context).canPop() ? Navigator.pop(context) : null,
        ),
        title: Text(
          'Chat',
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
                  Provider.of<UserSearchProvider>(context, listen: false).clearSearch();
                }
              });
            },
          ),
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
        bottom: _isSearching ? null : TabBar(
          controller: _tabController,
          indicatorColor: white,
          labelColor: white,
          unselectedLabelColor: white.withOpacity(0.7),
          tabs: [
            Tab(text: 'Conversations'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isSearching) _buildSearchBar(theme),
          Expanded(
            child: _isSearching
                ? _buildUserSearchResults(currentUserId, theme)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildConversationsList(currentUserId, theme),
                    ],
                  ),
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
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<UserSearchProvider>(context, listen: false).clearSearch();
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
    return Consumer<UserSearchProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.searchQuery.isEmpty) {
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

        if (searchProvider.isLoading) {
          return Center(child: CircularProgressIndicator(color: primaryPink));
        }

        if (searchProvider.searchResults.isEmpty) {
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

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: searchProvider.searchResults.length,
          itemBuilder: (context, index) {
            final userData = searchProvider.searchResults[index];
            final userId = userData['id'] as String;
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

  Widget _buildAllUsersList(String currentUserId, ThemeData theme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
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
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: Text('Retry'),
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

        final users = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final uid = data['uid'] as String? ?? doc.id;
          return uid != currentUserId;
        }).toList();
        
        // Sort users alphabetically by username on client side
        users.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aUsername = (aData['username'] as String?) ?? (aData['displayName'] as String?) ?? '';
          final bUsername = (bData['username'] as String?) ?? (bData['displayName'] as String?) ?? '';
          return aUsername.toLowerCase().compareTo(bUsername.toLowerCase());
        });

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final userId = userData['uid'] as String? ?? users[index].id;
            final username = userData['username'] as String? ?? userData['displayName'] as String? ?? 'Unknown';
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

  Widget _buildConversationsList(String currentUserId, ThemeData theme) {
    print('DEBUG: Building conversations list for user: $currentUserId');
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .snapshots(),
      builder: (context, snapshot) {
        print('DEBUG: Snapshot state: ${snapshot.connectionState}');
        print('DEBUG: Has data: ${snapshot.hasData}');
        if (snapshot.hasData) {
          print('DEBUG: Total conversations: ${snapshot.data!.docs.length}');
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            print('DEBUG: Conversation ${doc.id}: participants=${data['participants']}');
          }
        }
        
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

        final allConversations = snapshot.data!.docs;
        final conversations = allConversations.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final participants = (data['participants'] as List<dynamic>?) ?? [];
          return participants.contains(currentUserId);
        }).toList();
        
        print('DEBUG: Filtered conversations for user: ${conversations.length}');
        
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
                  // Try to get name from posts if user profile doesn't exist
                  return FutureBuilder<String>(
                    future: _getNameFromPosts(otherUserId),
                    builder: (context, nameSnapshot) {
                      final username = nameSnapshot.data ?? 'Unknown User';
                      return _buildConversationCard(
                        conversationId,
                        otherUserId,
                        username,
                        null,
                        lastMessage,
                        lastMessageTime,
                        theme,
                      );
                    },
                  );
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                final username = userData['displayName'] as String? ?? userData['username'] as String? ?? userData['email']?.split('@')[0] ?? 'Unknown';
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

  Future<String> _getNameFromPosts(String userId) async {
    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (postsSnapshot.docs.isNotEmpty) {
        final postData = postsSnapshot.docs.first.data();
        return postData['author'] as String? ?? 'Unknown User';
      }
    } catch (e) {
      print('Error getting name from posts: $e');
    }
    return 'Unknown User';
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

