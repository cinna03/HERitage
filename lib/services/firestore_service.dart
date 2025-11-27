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
}