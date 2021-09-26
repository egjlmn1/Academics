import 'package:academics/posts/postBuilder.dart';
import 'package:academics/posts/postCloudUtils.dart';
import 'package:academics/posts/model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../errors.dart';

class ChoosePostPage extends StatelessWidget {
  final List<String> filter;

  const ChoosePostPage({Key key, this.filter}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: FutureBuilder(
            future: fetchPosts(user: FirebaseAuth.instance.currentUser.uid, filter: false),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Post> posts = reduceByFilter(snapshot.data);
                if (posts.isEmpty) {
                  return Center(
                      child: Text('Nothing to send',
                          style: Theme.of(context).textTheme.headline2));
                }
                return ChoosePostList(
                  posts: posts,
                );
              } else if (snapshot.hasError) {
                return errorWidget('Error fetching posts', context);
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  List<Post> reduceByFilter(List<Post> posts) {
    posts.removeWhere((post) => !filter.contains(post.type));
    return posts;
  }
}

class ChoosePostList extends StatefulWidget {
  final List<Post> posts;

  const ChoosePostList({Key key, @required this.posts});

  @override
  _ChoosePostListState createState() => _ChoosePostListState();
}

class _ChoosePostListState extends State<ChoosePostList> {
  int _chosen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _chosen == null ? 'Choose a post' : 'Post Selected',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              if (_chosen != null)
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, widget.posts[_chosen].id);
                    },
                    child: Text('ok'))
            ],
          ),
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
                primary: false,
                itemCount: widget.posts.length,
                physics: ScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return OutlinedButton(
                    onPressed: () {
                      setState(() {
                        if (_chosen == index) {
                          _chosen = null;
                        } else {
                          _chosen = index;
                        }
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          _chosen == index
                              ? Theme.of(context).hintColor
                              : Theme.of(context).cardColor),
                    ),
                    child:
                        PostBuilder(post: widget.posts[index], context: context)
                            .buildHintPost(),
                  );
                }),
          ),
        ),
      ],
    );
  }
}
