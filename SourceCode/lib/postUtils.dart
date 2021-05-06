
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:academics/schemes.dart';
import 'package:flutter/cupertino.dart';

Future<List<ShowPost>> fetchPosts() async {
  print('getting response');
  try {
    final response = await http.get('http://10.0.2.2:3000/posts/home_posts')
        .timeout(const Duration(seconds: 10));

    print('got response');
    print(response);
    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<ShowPost> posts = [];
      for (Map data in jsonDecode(response.body)) {
        posts.add(ShowPost.fromJson(data));
      }
      return posts;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      throw Exception('Failed to load posts');
    }
  } on TimeoutException {
    throw Exception('Timeout');
    //throw Exception('Academics is currently under maintenance');
  }
}

Widget createPosts(futurePosts) {
  return FutureBuilder<List<ShowPost>>(
    future: futurePosts,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ListView.builder(
            itemCount: snapshot.data.length,
            physics: ScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: createPost(snapshot.data[index]),
              );
            }
        );
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
                Text(post.votes.toString()),
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
