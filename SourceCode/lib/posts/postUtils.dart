import 'dart:async';
import 'dart:convert';

import 'package:academics/folders/folders.dart';
import 'package:flutter/material.dart';

import 'package:academics/posts/schemes.dart';
import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../cloudUtils.dart';
import '../folders/foldersUtil.dart';

Post decodePost(QueryDocumentSnapshot data) {
  Map m = data.data();
  m['id'] = data.id;
  return Post.fromJson(m);
}

Widget createPostsList(List<Post> posts, BuildContext context) {
  return ListView.builder(
      itemCount: posts.length,
      physics: ScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: createPost(posts[index], context),
        );
      });
}

Future<List<Post>> fetchPosts(String posts_endpoint) async {
  CollectionReference ref = FirebaseFirestore.instance.collection('posts'); //TODO switch to endpoint
  List<Post> posts = (await ref.get()).docs.map((e)=>decodePost(e)).toList();
  return posts;
}

Widget createPostPage(String posts_endpoint, BuildContext context) {
  return FutureBuilder<List<Post>>(
    future: fetchPosts(posts_endpoint),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return createPostsList(snapshot.data, context);
      } else if (snapshot.hasError) {
        return Text(snapshot.error
            .toString()
            .substring(11)); //removes the 'Exception: ' prefix
      }
      return Container();
    },
  );
}

Widget createPost(Post post, BuildContext context) {
  return PostCreator(post: post, context: context).buildPost();
}

class PostCreator {
  Post post;
  BuildContext context;

  PostCreator({this.post, this.context});

  Widget buildPost() {
    return Card(
        child: Column(
      children: [
        createPostTopBar(post),
        Divider(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          alignment: Alignment.topLeft,
          child: Text(
            post.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          child: post.typeData.createWidget(),
        ),
      ],
    ));
  }

  Widget buildPostPage() {
    return Column(
      children: [
        buildPost(),
        //TODO comments
      ],
    );
  }

  Widget createPostTopBar(Post post) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(post.type),
              Text(post.folder.split('\\').last),
              PopupMenuButton<String>(
                onSelected: postActionSelect,
                itemBuilder: (BuildContext context) {
                  return PostActions.values.map((PostActions choice) {
                    return PopupMenuItem<String>(
                      child: Text(choice.toString().split('.')[1]),
                      value: choice.toString(),
                    );
                  }).toList();
                },
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(post.username),
              if (post.university != null) Text(post.university)
            ],
          ),
        ],
      ),
    );
  }

  void savePost() async {
    var folders = getUserFolders();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 16,
          child: Container(
            child: createFolders(folders),
          ),
        );
      },
    );
  }

  Widget createFolders(List<Folder> folders) {
    var buttons = List.generate(folders.length, (index) {
      return TextButton(
        onPressed: () {},
        child: folders[index].build(),
      );
    });
    buttons.add(TextButton(
      onPressed: () {

      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Create new Folder',
                style: TextStyle(
                  fontSize: 25,
                ),
              textAlign: TextAlign.center,

            ),
            Icon(Icons.add, size: 25,),
          ],
        ),
      ),
    ));
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 4.0,
      mainAxisSpacing: 4.0,
      children: buttons,
    );
  }

  void postActionSelect(String choice) {
    if (choice == PostActions.Save.toString()) {
      savePost();
    } else if (choice == PostActions.Delete.toString()) {
      deleteObject('posts', post.id);
    } else {}
  }


}



enum PostActions {
  Save,
  Delete,
}
