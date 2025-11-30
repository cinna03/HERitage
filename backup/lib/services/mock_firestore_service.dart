class MockFirestoreService {
  static List<Map<String, dynamic>> _posts = [];

  Future<void> createPost(Map<String, dynamic> postData) async {
    await Future.delayed(Duration(milliseconds: 300));
    postData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    postData['timestamp'] = DateTime.now();
    _posts.insert(0, postData);
  }

  Stream<List<Map<String, dynamic>>> getPosts() {
    return Stream.value(_posts);
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 200));
    final index = _posts.indexWhere((post) => post['id'] == postId);
    if (index != -1) {
      _posts[index].addAll(data);
    }
  }

  Future<void> deletePost(String postId) async {
    await Future.delayed(Duration(milliseconds: 200));
    _posts.removeWhere((post) => post['id'] == postId);
  }
}