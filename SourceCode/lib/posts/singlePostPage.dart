import 'package:academics/posts/postBuilder.dart';
import 'package:academics/posts/postCloudUtils.dart';
import 'package:flutter/material.dart';

class SinglePostPage extends StatefulWidget {

  final String postId;

  const SinglePostPage({Key key, this.postId}) : super(key: key);

  @override
  _SinglePostPageState createState() => _SinglePostPageState();
}

class _SinglePostPageState extends State<SinglePostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).accentColor,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: fetchPost(widget.postId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return PostBuilder(post: snapshot.data, context: context).buildFullPost();
            }
            if (snapshot.hasError) {
              return PostBuilder(post: snapshot.data, context: context).buildFullPost();
            }
            return Container();
          },
        )
      ),
    );
  }
}
