import 'dart:async';
import 'dart:convert';

import 'package:academics/events.dart';
import 'package:academics/posts/postUtils.dart';
import 'package:academics/posts/schemes.dart';
import 'package:flutter/material.dart';

class PostsPage extends StatefulWidget {
  EventHandler eventHandler;
  PostsPage({this.eventHandler});

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  Widget posts;

  @override
  void initState() {
    super.initState();
    posts = createPostPage('posts', context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Column(children: [
              TextButton(
                onPressed: () => {Navigator.pushNamed(context, '/post_search')},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      Text('search'),
                      Icon(Icons.search),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                child: Row(
                  children: [
                    Text('test'),
                  ],
                ),
              )
            ]),
          ),
          Expanded(
            child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    posts = createPostPage('posts', context);
                  });
                  return;
                },
                child: posts),
          ),
        ],
      ),
    );
  }
}
