import 'dart:async';
import 'package:academics/folders/folders.dart';
import 'package:academics/cloud/httpUtils.dart';
import 'package:academics/user/model.dart';
import 'package:academics/user/userUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:academics/posts/model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../cloud/firebaseUtils.dart';


Future<List<Post>> fetchPosts(
    {List<String> ids, Folder folder, String user, bool filter = true}) async {
  List docs;
  if (ids != null) {
    docs = await fetchInBatches(Collections.posts, ids);
  } else if (folder != null) {
    try {
      String folderId;
      String collection;
      if (folder.type == FolderType.folder) {
        folderId = await findDocId(Collections.folders, 'path', folder.path);
        collection = Collections.folders;
      } else if (folder.type == FolderType.user) {
        folderId = folder.path;
        collection = Collections.userFolders;
        //In userFolder save the folder path to be the id because may have multiple folders with same name for different users
      } else {
        print('folder has no type');
        return [];
      }
      List<String> ids = List.from((await FirebaseFirestore.instance
              .collection(collection)
              .doc(folderId)
              .collection(Collections.posts)
              .get())
          .docs
          .map((e) => e.get('id').toString()));

      if (ids.isEmpty) {
        return [];
      }
      docs = await fetchInBatches(Collections.posts, ids);
    } catch (e) {
      print('fetchPosts $e');
      return [];
    }
  } else if (user != null) {
    try {
      List<String> ids = (await fetchUser(user)).posts;
      docs = await fetchInBatches(Collections.posts, ids);
    } catch (e) {
      docs = [];
    }
  } else {
    Query ref = FirebaseFirestore.instance.collection(Collections.posts);
    docs = (await (ref).get()).docs;
  }
  List<Post> posts = List.from(docs.map((e) => Post.decode(e)));
  if (filter) {
    posts = await filterPosts(posts);
  }
  posts.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));

  return posts;
}

Future<List<Post>> fetchSmartPosts({String search = '', String lastId, bool filter = true}) async {
  List<Post> posts = await fetchHttpPosts(search, FetchConstant.fetchPostsLimit, lastId: lastId);
  if (filter) {
    posts = await filterPosts(posts);
  }
  return posts;
}

Future<List<Post>> filterPosts(List<Post> posts) async {
  try {
    AcademicsUser user = await fetchUser(FirebaseAuth.instance.currentUser.uid);
    List<String> filtered = PostType.filtered(user.filters);
    posts = List.from(posts.where((post) => filtered.contains(post.type)));
  } catch (e) {
    print('filterPosts $e');
  }
  return posts;
}

Future<Post> fetchPost(String id) async {
  DocumentReference ref =
      FirebaseFirestore.instance.collection(Collections.posts).doc(id);
  Post post = Post.decode(await ref.get());
  return post;
}

Future<void> addToFolder(String id, String folder) async {
  var folderId = await findDocId(Collections.folders, 'path', folder);
  await uploadObject(Collections.folders, {'id': id},
      doc: folderId, subCollection: Collections.posts);
}
