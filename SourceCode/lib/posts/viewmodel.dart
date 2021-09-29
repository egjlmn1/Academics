import 'package:academics/chat/model.dart';
import 'package:academics/cloud/firebaseUtils.dart';
import 'package:academics/inbox/message.dart';
import 'package:academics/posts/postCloudUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'model.dart';

class SearchPostsListViewModel with ChangeNotifier {
  String _searchTerm = '';
  String _lastPostId;

  List<Post> posts = [];

  set search(String value) {
    _searchTerm = value;
    _lastPostId = null;
    notifyListeners();
  }

  get search {
    return _searchTerm;
  }

  set lastPostId(String value) {
    _lastPostId = value;
    notifyListeners();
  }

  Future<List<Post>> get postsList async {
    List<Post> loadedPosts = await fetchSmartPosts(search: _searchTerm, lastId: _lastPostId);
    if (_lastPostId != null) {
      posts.addAll(loadedPosts);
      return posts;
    }
    posts = loadedPosts;
    return posts;
  }
}

class SinglePostViewModel with ChangeNotifier {
  final Post post;

  SinglePostViewModel(this.post);

  int get votes {
    return post.upVotes - post.downVotes;
  }

  Future<List<Chat>> get currentUserChats async {
    List<String> chatsIds = List.from((await getDocs(Collections.users,
            doc: FirebaseAuth.instance.currentUser.uid,
            subCollection: Collections.chat))
        .map((e) => e.id));

    List<Chat> chats = List.from(
        (await fetchInBatches(Collections.chat, chatsIds))
            .map((doc) => Chat.decode(doc)));
    return chats;
  }

  Future movePost(String path) {
    updateObject(Collections.posts, post.id, 'folder', path);
    _deleteFromFolder();
    return addToFolder(post.id, path);
  }

  Future deletePost() {
    if (post.typeData.file() != null) {
      deleteFile(post.typeData.file());
    }
    return Future.wait([
      _deleteFromFolder(),
      removeFromObject(Collections.users, post.userid, 'posts', post.id),
      _deleteComments(),
      deleteObject(Collections.posts, post.id)
    ]);
  }

  Future<void> _deleteComments() async {
    return FirebaseFirestore.instance
        .collection(Collections.posts)
        .doc(post.id)
        .collection(Collections.comments)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  Future<void> _deleteFromFolder() async {
    try {
      String folderId =
          await findDocId(Collections.folders, 'path', post.folder);
      deleteObject(
          Collections.folders,
          (await findDocId(Collections.folders, 'id', post.id,
              doc: folderId, subCollection: Collections.posts)),
          doc: folderId,
          subCollection: Collections.posts);
    } catch (e) {
      print('error in deleting from folder: $e');
    }
  }

  Future<String> getFileUrl(String fileId) {
    return FirebaseStorage.instance.ref(fileId).getDownloadURL();
  }

  Future like(bool activate) {
    if (activate) {
      return Future.wait([
        addToObject(Collections.users, FirebaseAuth.instance.currentUser.uid,
            'liked', post.id),
        updateObject(
            Collections.posts, post.id, 'up_votes', FieldValue.increment(1)),
        updateObject(
            Collections.users, post.userid, 'points', FieldValue.increment(1)),
      ]);
    } else {
      return Future.wait([
        removeFromObject(Collections.users,
            FirebaseAuth.instance.currentUser.uid, 'liked', post.id),
        updateObject(
            Collections.posts, post.id, 'up_votes', FieldValue.increment(-1)),
        updateObject(
            Collections.users, post.userid, 'points', FieldValue.increment(-1)),
      ]);
    }
  }

  Future dislike(bool activate) {
    if (activate) {
      return Future.wait([
        addToObject(Collections.users, FirebaseAuth.instance.currentUser.uid,
            'disliked', post.id),
        updateObject(
            Collections.posts, post.id, 'down_votes', FieldValue.increment(1)),
        updateObject(
            Collections.users, post.userid, 'points', FieldValue.increment(-1)),
      ]);
    } else {
      return Future.wait([
        removeFromObject(Collections.users,
            FirebaseAuth.instance.currentUser.uid, 'disliked', post.id),
        updateObject(
            Collections.posts, post.id, 'down_votes', FieldValue.increment(-1)),
        updateObject(
            Collections.users, post.userid, 'points', FieldValue.increment(1)),
      ]);
    }
  }

  Stream get comments {
    return FirebaseFirestore.instance
        .collection(Collections.posts)
        .doc(post.id)
        .collection(Collections.comments)
        .orderBy('time')
        .snapshots()
        .map((event) => List<Map<String, dynamic>>.from(event.docs.map((doc) {
              var data = doc.data();
              data.addAll({'id': doc.id});
              return data;
            })));
  }

  Future<void> notifyFollower({@required String msg, String postToSend}) async {
    List<String> followers = post.typeData.getFollowers();
    for (String follower in followers) {
      sendMessage(
          Message(
              title: 'Post update',
              msg: msg,
              time: DateTime.now().millisecondsSinceEpoch,
              sender: null,
              post: postToSend),
          follower);
    }
    return updateObject(Collections.posts, post.id, 'typeData.followers', []);
  }
}
