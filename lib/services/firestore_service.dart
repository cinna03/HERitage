import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for handling Firestore database operations
/// Provides CRUD operations for posts, users, events, courses, and chat
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== Forum Posts CRUD ====================
  
  /// Creates a new forum post in Firestore
  /// [postData] should contain: title, content, author, userId, timestamp, likes, comments
  Future<void> createPost(Map<String, dynamic> postData) async {
    await _db.collection('posts').add(postData);
  }

  /// Gets all posts ordered by timestamp (newest first) as a real-time stream
  Stream<QuerySnapshot> getPosts() {
    return _db.collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Updates a post with new data
  /// [postId] is the Firestore document ID
  /// [data] contains the fields to update
  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _db.collection('posts').doc(postId).update(data);
  }

  /// Deletes a post from Firestore
  /// [postId] is the Firestore document ID
  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  // ==================== User Profile CRUD ====================
  
  /// Creates a new user profile in Firestore
  /// [userId] is the Firebase Auth UID
  /// [userData] contains user profile information
  Future<void> createUserProfile(String userId, Map<String, dynamic> userData) async {
    await _db.collection('users').doc(userId).set(userData);
  }

  /// Gets a user profile by user ID
  /// Returns a DocumentSnapshot that may or may not exist
  Future<DocumentSnapshot> getUserProfile(String userId) {
    return _db.collection('users').doc(userId).get();
  }

  /// Updates a user profile with new data
  /// [userId] is the Firebase Auth UID
  /// [data] contains the fields to update
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  /// Searches for users by username
  /// Returns a stream of users matching the search query
  /// Note: This uses a simple query without range filters to avoid index requirements
  /// Filtering is done in memory for case-insensitive matching
  Stream<QuerySnapshot> searchUsers(String query) {
    if (query.isEmpty) {
      // Return empty stream if query is empty
      return _db.collection('users').limit(0).snapshots();
    }
    
    // Get all users and filter in memory (avoids index requirement)
    // This is more reliable than range queries which need indexes
    return _db.collection('users')
        .limit(100) // Get up to 100 users and filter in memory
        .snapshots();
  }

  /// Gets all users (for search functionality)
  /// Returns a stream of all users
  Stream<QuerySnapshot> getAllUsers() {
    return _db.collection('users').limit(50).snapshots();
  }

  // ==================== Events CRUD ====================
  
  /// Creates a new event in Firestore
  /// [eventData] should contain: title, description, dateTime, type, host, location, userId
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    await _db.collection('events').add(eventData);
  }

  /// Gets all events ordered by dateTime (upcoming first) as a real-time stream
  Stream<QuerySnapshot> getEvents() {
    return _db.collection('events').orderBy('dateTime').snapshots();
  }

  /// Adds a user to an event's attendees list (RSVP)
  /// [eventId] is the Firestore document ID
  /// [userId] is the Firebase Auth UID
  Future<void> rsvpEvent(String eventId, String userId) async {
    await _db.collection('events').doc(eventId).update({
      'attendees': FieldValue.arrayUnion([userId])
    });
  }

  /// Removes a user from an event's attendees list (Cancel RSVP)
  /// [eventId] is the Firestore document ID
  /// [userId] is the Firebase Auth UID
  Future<void> cancelRSVP(String eventId, String userId) async {
    await _db.collection('events').doc(eventId).update({
      'attendees': FieldValue.arrayRemove([userId])
    });
  }

  /// Checks if a user has RSVPed to an event
  /// Returns true if user is in the attendees list, false otherwise
  Future<bool> isUserRSVPed(String eventId, String userId) async {
    final doc = await _db.collection('events').doc(eventId).get();
    if (!doc.exists) return false;
    final data = doc.data();
    final attendees = data?['attendees'] ?? [];
    return attendees.contains(userId);
  }

  // ==================== Chat Messages CRUD ====================
  Future<void> sendChatMessage(String chatRoomId, Map<String, dynamic> messageData) async {
    await _db.collection('chatRooms').doc(chatRoomId).collection('messages').add(messageData);
  }

  Stream<QuerySnapshot> getChatMessages(String chatRoomId) {
    return _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> createChatRoom(Map<String, dynamic> roomData) async {
    await _db.collection('chatRooms').add(roomData);
  }

  Stream<QuerySnapshot> getChatRooms() {
    return _db.collection('chatRooms').orderBy('createdAt', descending: true).snapshots();
  }

  // ==================== Direct Messages CRUD ====================
  
  /// Gets or creates a conversation ID between two users
  /// Returns a conversation ID that can be used for messaging
  Future<String> getOrCreateConversation(String userId1, String userId2) async {
    // Sort user IDs to ensure consistent conversation ID
    final sortedIds = [userId1, userId2]..sort();
    final conversationId = '${sortedIds[0]}_${sortedIds[1]}';
    
    // Check if conversation exists
    final conversationDoc = await _db.collection('conversations').doc(conversationId).get();
    
    if (!conversationDoc.exists) {
      // Create new conversation with a default timestamp (not null) so queries work
      final now = DateTime.now();
      await _db.collection('conversations').doc(conversationId).set({
        'participants': [userId1, userId2],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageTime': Timestamp.fromDate(now), // Use current time instead of null
      });
    }
    
    return conversationId;
  }

  /// Sends a direct message between two users
  /// [conversationId] is the conversation ID (from getOrCreateConversation)
  /// [messageData] contains: text, senderId, senderName, timestamp
  Future<void> sendDirectMessage(String conversationId, Map<String, dynamic> messageData) async {
    // Add message to conversation
    await _db.collection('conversations').doc(conversationId)
        .collection('messages').add(messageData);
    
    // Update conversation last message
    await _db.collection('conversations').doc(conversationId).update({
      'lastMessage': messageData['text'],
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Gets messages for a conversation as a real-time stream
  /// [conversationId] is the conversation ID
  Stream<QuerySnapshot> getDirectMessages(String conversationId) {
    return _db.collection('conversations').doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// Gets all conversations for a user
  /// Uses cache-first approach: loads from cache immediately, then syncs with server
  /// Note: Sorting is done in memory to avoid index requirements
  /// [userId] is the current user's ID
  Stream<QuerySnapshot> getUserConversations(String userId) {
    // Query without orderBy to avoid index requirement - sorting done in UI
    return _db.collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots(includeMetadataChanges: false);
  }

  // ==================== Course Progress CRUD ====================
  Future<void> updateCourseProgress(String userId, String courseId, Map<String, dynamic> progressData) async {
    await _db.collection('users').doc(userId).collection('courseProgress').doc(courseId).set(progressData, SetOptions(merge: true));
  }

  Future<DocumentSnapshot?> getCourseProgress(String userId, String courseId) async {
    return await _db.collection('users').doc(userId).collection('courseProgress').doc(courseId).get();
  }

  Stream<QuerySnapshot> getUserCourseProgress(String userId) {
    return _db.collection('users').doc(userId).collection('courseProgress').snapshots();
  }

  Future<void> markCourseComplete(String userId, String courseId) async {
    await _db.collection('users').doc(userId).collection('courseProgress').doc(courseId).set({
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
      'progress': 100,
    }, SetOptions(merge: true));
  }

  // ==================== Courses CRUD ====================
  Future<void> createCourse(Map<String, dynamic> courseData) async {
    await _db.collection('courses').add(courseData);
  }

  Stream<QuerySnapshot> getCourses() {
    return _db.collection('courses').orderBy('createdAt', descending: true).snapshots();
  }

  Future<DocumentSnapshot> getCourse(String courseId) {
    return _db.collection('courses').doc(courseId).get();
  }

  /// Gets a single event by ID
  Future<DocumentSnapshot> getEvent(String eventId) {
    return _db.collection('events').doc(eventId).get();
  }

  // ==================== User Statistics ====================
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    // Get all course progress (both completed and in-progress)
    final allProgressSnapshot = await _db.collection('users').doc(userId).collection('courseProgress').get();
    
    // Get courses completed
    final coursesCompleted = allProgressSnapshot.docs.where((doc) {
      final data = doc.data();
      return data['completed'] == true;
    }).length;

    // Get posts count - check both 'userId' and 'author' fields for compatibility
    final postsByUserId = await _db.collection('posts').where('userId', isEqualTo: userId).get();
    final postsByAuthor = await _db.collection('posts').where('author', isEqualTo: userId).get();
    // Combine and deduplicate by post ID
    final allPostIds = <String>{};
    postsByUserId.docs.forEach((doc) => allPostIds.add(doc.id));
    postsByAuthor.docs.forEach((doc) => allPostIds.add(doc.id));
    final postsCount = allPostIds.length;

    // Get total hours learned (sum of hoursSpent from all progress, not just completed)
    int totalHours = 0;
    for (var doc in allProgressSnapshot.docs) {
      final data = doc.data();
      final hoursSpent = data['hoursSpent'] as int? ?? 0;
      totalHours += hoursSpent;
    }

    // Get certificates earned
    final certificatesSnapshot = await _db.collection('users').doc(userId).collection('certificates').get();
    final certificatesCount = certificatesSnapshot.docs.length;

    return {
      'coursesCompleted': coursesCompleted,
      'postsCount': postsCount,
      'totalHours': totalHours,
      'certificatesEarned': certificatesCount,
    };
  }

  // ==================== Comments for Posts ====================
  
  /// Gets comments for a specific post as a stream
  Stream<QuerySnapshot> getPostComments(String postId) {
    return _db.collection('posts').doc(postId).collection('comments')
        .orderBy('timestamp', descending: false).snapshots();
  }

  /// Adds a comment to a post
  Future<void> addComment(String postId, Map<String, dynamic> commentData) async {
    await _db.collection('posts').doc(postId).collection('comments').add(commentData);
  }

  /// Updates the comment count for a post
  Future<void> updatePostCommentCount(String postId, int newCount) async {
    await _db.collection('posts').doc(postId).update({'comments': newCount});
  }

  // ==================== Certificates ====================
  
  /// Creates a certificate for a user after course completion
  Future<void> createCertificate(String userId, Map<String, dynamic> certificateData) async {
    await _db.collection('users').doc(userId).collection('certificates').add(certificateData);
  }

  // ==================== Notifications ====================
  
  /// Creates a notification for a user
  Future<void> createNotification(String userId, Map<String, dynamic> notificationData) async {
    await _db.collection('users').doc(userId).collection('notifications').add(notificationData);
  }

  /// Gets notifications for a user as a stream
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _db.collection('users').doc(userId).collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }
}
