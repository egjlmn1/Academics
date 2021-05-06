import 'dart:async';
import 'dart:convert';

import 'package:academics/postUtils.dart';
import 'package:academics/schemes.dart';
import 'package:flutter/material.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  Future<List<ShowPost>> futurePosts;

  List<ShowPost> posts = [
    ShowPost(
      username: 'Yoav Naftali',
      folder: 'Exact Science/Computer Science',
      title: 'An interesting title',
      type: PostType.File,
      university: 'Bar Ilan',
      typeData: FileDataWidget(
          context: 'My very long and annoying question'
      ),
      votes: 5,
    ),
    ShowPost(
      username: 'Yoav Naftali',
      folder: 'Exact Science/Computer Science',
      title: 'An interesting title',
      type: PostType.Question,
      university: 'Bar Ilan',
      typeData: QuestionDataWidget(
          data: 'My very very very very very very very very very very very very very very very very long and annoying question'
      ),
      votes: 5,
    ),
    ShowPost(
      username: 'Yoav Naftali',
      folder: 'Exact Science/Computer Science',
      title: 'An interesting title',
      type: PostType.Poll,
      university: 'Bar Ilan',
      typeData: PollDataWidget(
        question: 'My very long and annoying question',
        polls: {'my very long option number unu in spanish and one in english but after all one in english in ich in japanese and ich in english makes you want to scratch': 5, 'b': 5, 'c': 5},
        voted: false,
      ),
      votes: 5,
    ),
    ShowPost(
      username: 'Yoav Naftali',
      folder: 'Exact Science/Computer Science',
      title: 'An interesting title',
      type: PostType.Poll,
      typeData: PollDataWidget(
        question: 'My very long and annoying question',
        polls: {'my very long option number unu in spanish and one in english but after all one in english in ich in japanese and ich in english makes you want to scratch': 8, 'b': 15, 'c': 12},
        voted: true,
      ),
      votes: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                TextButton(
                  onPressed: () => {
                    Navigator.pushNamed(context, '/post_search')
                  },
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
                  color: Colors.black,
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
              ]
            ),
          ),
          Expanded(
            child: createPosts(futurePosts),
          ),
        ],
      ),
    );
  }
}
