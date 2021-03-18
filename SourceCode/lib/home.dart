import 'package:academics/schemes.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


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
                FlatButton(
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
            child: ListView.builder(
                itemCount: posts.length,
                physics: ScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: createPost(index),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget createPost(int index) {
    ShowPost post = posts[index];
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
        Text(post.type.toString().split('.')[1]),
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

}
