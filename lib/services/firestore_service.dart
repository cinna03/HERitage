import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Forum Posts CRUD
  Future<void> createPost(Map<String, dynamic> postData) async {
    await _db.collection('posts').add(postData);
  }

  Stream<QuerySnapshot> getPosts() {
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _db.collection('posts').doc(postId).update(data);
  }

  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  // User Profile CRUD
  Future<void> createUserProfile(String userId, Map<String, dynamic> userData) async {
    await _db.collection('users').doc(userId).set(userData);
  }

  Future<DocumentSnapshot> getUserProfile(String userId) {
    return _db.collection('users').doc(userId).get();
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  // Events CRUD
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    await _db.collection('events').add(eventData);
  }

  Stream<QuerySnapshot> getEvents() {
    return _db.collection('events').orderBy('dateTime').snapshots();
  }

  Future<void> rsvpEvent(String eventId, String userId) async {
    await _db.collection('events').doc(eventId).update({
      'attendees': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> cancelRSVP(String eventId, String userId) async {
    await _db.collection('events').doc(eventId).update({
      'attendees': FieldValue.arrayRemove([userId])
    });
  }

  Future<bool> isUserRSVPed(String eventId, String userId) async {
    final doc = await _db.collection('events').doc(eventId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>?;
    final attendees = data?['attendees'] as List<dynamic>? ?? [];
    return attendees.contains(userId);
  }

  // Chat Messages CRUD
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

  // Course Progress CRUD
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

  // Courses CRUD
  Future<void> createCourse(Map<String, dynamic> courseData) async {
    await _db.collection('courses').add(courseData);
  }

  Stream<QuerySnapshot> getCourses() {
    return _db.collection('courses').orderBy('createdAt', descending: true).snapshots();
  }

  Future<DocumentSnapshot> getCourse(String courseId) {
    return _db.collection('courses').doc(courseId).get();
  }

  // User Statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    // Get courses completed
    final progressSnapshot = await _db.collection('users').doc(userId).collection('courseProgress')
        .where('completed', isEqualTo: true).get();
    final coursesCompleted = progressSnapshot.docs.length;

    // Get posts count
    final postsSnapshot = await _db.collection('posts').where('authorId', isEqualTo: userId).get();
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

  // Comments for posts
  Stream<QuerySnapshot> getPostComments(String postId) {
    return _db.collection('posts').doc(postId).collection('comments')
        .orderBy('timestamp', descending: false).snapshots();
  }
}