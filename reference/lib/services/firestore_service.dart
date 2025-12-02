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
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots();
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
    // Get courses completed
    final progressSnapshot = await _db.collection('users').doc(userId).collection('courseProgress')
        .where('completed', isEqualTo: true).get();
    final coursesCompleted = progressSnapshot.docs.length;

    // Get posts count
    final postsSnapshot = await _db.collection('posts').where('userId', isEqualTo: userId).get();
    final postsCount = postsSnapshot.docs.length;

    // Get total hours learned (sum of course durations)
    int totalHours = 0;
    for (var doc in progressSnapshot.docs) {
      final data = doc.data();
      totalHours += (data['hoursSpent'] as int? ?? 0);
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
}