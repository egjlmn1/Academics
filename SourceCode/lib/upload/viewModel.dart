import 'dart:io';
import 'package:academics/cloud/firebaseUtils.dart';
import 'package:academics/posts/model.dart';
import 'package:academics/posts/postCloudUtils.dart';
import 'package:academics/upload/uploadType.dart';
import 'package:academics/user/userUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UploadPageViewModel with ChangeNotifier {
  final UploadType postType;

  String folder = 'root';
  List<String> _tags = [];

  UploadPageViewModel(this.postType);

  get tags {
    return _tags;
  }


  Future<String> postClicked() async {
    try {
      Post post = Post(
        username: (await fetchUser(FirebaseAuth.instance.currentUser.uid)).displayName,
        userid: FirebaseAuth.instance.currentUser.uid,
        folder: folder,
        title: await postType.title(),
        uploadTime: DateTime.now().millisecondsSinceEpoch,
        upVotes: 0,
        downVotes: 0,
        tags: _tags.toSet().toList(),
        type: postType.type,
      );
      return await sendPost(post);
    } catch(e) {
      return null;
    }
  }

  Future<String> sendPost(Post post) async {
    /**
     * create the data type of the post
     * if needs to upload to cloud storage, get the path to the file
     * returns the id of the post
     */

    DocumentReference d = FirebaseFirestore.instance.collection('posts').doc();
    String id = d.id;
    String path;
    File f = postType.file();
    if (f != null) {
      String name;
      try {
        name = id + '.' + f.path.split('.').last;
      } catch (e) {
        name = id;
      }
      path = await uploadFile(f, 'postFiles/$name');
    }
    post.typeData = postType.createDataObject(path);
    d.set(post.toJson());
    await addToFolder(id, folder);

    await addToObject(
        Collections.users, FirebaseAuth.instance.currentUser.uid, 'posts', id);

    print('post uploaded $id');
    return id;
  }
}