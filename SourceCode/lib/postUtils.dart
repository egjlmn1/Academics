
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:academics/schemes.dart';
import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


Widget createPosts(QuerySnapshot data) {
    List<ShowPost> posts = [];
    for (QueryDocumentSnapshot doc in data.docs) {
      Map m = doc.data();
      print(m);
      posts.add(ShowPost.fromJson(m));
    }
    return ListView.builder(
        itemCount: posts.length,
        physics: ScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: createPost(posts[index]),
          );
        }
    );
}

Widget fetchPosts(String posts_name) {
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  return FutureBuilder<QuerySnapshot>(
    future: posts.get(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return createPosts(snapshot.data);
      } else if (snapshot.hasError) {
        return Text(snapshot.error.toString().substring(11)); //removes the 'Exception: ' prefix
      }
      return Container();
    },
  );
}

Widget createPost(ShowPost post) {
  return Card(
      child: Column(
        children: [
          createPostTopBar(post),
          Divider(color: Colors.black),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            alignment: Alignment.topLeft,
            child: Text(post.title,style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          Container(
            alignment: Alignment.topLeft,
            child: post.typeData.createWidget(),
          ),
          Divider(color: Colors.black),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.arrow_upward),
                Text((post.upVotes-post.downVotes).toString()),
                Icon(Icons.share),
              ],
            ),
          ),
        ],
      )
  );
}

Widget createPostTopBar(ShowPost post) {
  Widget top = Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(post.type),
      Text(post.folder.split('/').last),
    ],
  );
  if (post.university == null) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          top,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(post.username),
            ],
          ),
        ],
      ),
    );
  } else {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          top,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(post.username),
              Text(post.university),
            ],
          ),
        ],
      ),
    );
  }
}
