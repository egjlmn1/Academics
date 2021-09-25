import 'dart:async';
import 'package:academics/folders/folders.dart';
import 'package:academics/posts/postBuilder.dart';
import 'package:academics/user/httpUtils.dart';
import 'package:academics/user/user.dart';
import 'package:academics/user/userUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:academics/posts/schemes.dart';
import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

import '../cloudUtils.dart';
import '../errors.dart';

int fetchPostsLimit = 100;

Post decodePost(data) {
  Map m = data.data();
  m['id'] = data.id;
  return Post.fromJson(m);
}

List<Widget> createPostsList(List<Post> posts, BuildContext context) {
  return [
    for (Post post in posts)
      OutlinedButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/post_page', arguments: post.id);
        },
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).cardColor),
        ),
        child: PostCreator(post: post, context: context).buildHintPost(),
      )
  ];
}

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
  List<Post> posts = List.from(docs.map((e) => decodePost(e)));
  if (filter) {
    posts = await filterPosts(posts);
  }
  posts.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));

  return posts;
}

Future<List<Post>> fetchSmartPosts({String search = '', int limit = 100, String lastId, bool filter = true}) async {
  List<Post> posts = await fetchHttpPosts(search, limit, lastId: lastId);
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
  Post post = decodePost(await ref.get());
  return post;
}

Future<void> addToFolder(String id, String folder) async {
  var folderId = await findDocId(Collections.folders, 'path', folder);
  await uploadObject(Collections.folders, {'id': id},
      doc: folderId, subCollection: Collections.posts);
}

Widget createPostPage(Future<List<Post>> posts, BuildContext context,
    {Function loadMore}) {
  return Container(
    color: Theme.of(context).backgroundColor,
    child: FutureBuilder<List<Post>>(
      future: posts,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isEmpty) {
            return Center(
                child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No posts',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline2),
                ),
              ],
            ));
          }
          return ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              for (Widget post in createPostsList(snapshot.data, context)) post,
              if (loadMore != null && snapshot.data.length == fetchPostsLimit)
                OutlinedButton(
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Text('Load more'),
                          Icon(Icons.add_circle_outline),
                        ],
                      )),
                  onPressed: () {
                    loadMore(snapshot.data.last.id);
                  },
                )
            ],
          );
        } else if (snapshot.hasError) {
          print(snapshot
              .error); // .substring(11)); //removes the 'Exception: ' prefix
          return errorWidget('An error occured while fetching posts', context);
        }
        return Container();
      },
    ),
  );
}

String timeToText(int time) {
  DateTime now = DateTime.now();
  DateTime then = DateTime.fromMillisecondsSinceEpoch(time);
  Duration timeAgo = now.difference(then);
  if (timeAgo.inDays > 3 || timeAgo.inSeconds < 0) {
    return DateFormat('dd/MM/yy').format(then);
  } else if (timeAgo.inHours > 23) {
    return '${timeAgo.inDays} days ago';
  } else if (timeAgo.inMinutes > 59) {
    return '${timeAgo.inHours} hours ago';
  } else if (timeAgo.inSeconds > 59) {
    return '${timeAgo.inMinutes} mins ago';
  } else {
    return '${timeAgo.inSeconds} secs ago';
  }
}
