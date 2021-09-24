import 'dart:async';

import 'package:academics/posts/postUtils.dart';
import 'package:academics/posts/schemes.dart';
import 'package:flutter/material.dart';

class PostsPage extends StatefulWidget {
  PostsPage();

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  Future<List<Post>> posts;

  String lastPostId;
  String search = '';

  @override
  void initState() {
    super.initState();
    print('init posts');
  }

  @override
  Widget build(BuildContext context) {
    //print('build posts page');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          child: Column(children: [
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    var s = await Navigator.of(context).pushNamed('/post_search');
                    print(s);
                    setState(() {
                      search = (s==null)?search:s;
                    });
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
                if (search != '')
                  Flexible(
                    child: TextButton(
                      child: Row(
                        children: [
                          Flexible(child: Text(search, overflow: TextOverflow.ellipsis,)),
                          Icon(Icons.close),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          search='';
                        });
                      },
                    ),
                  ),
              ],
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
              onRefresh: _refreshData,
              child: createPostPage(fetchSmartPosts(search: search, limit: fetchPostsLimit, lastId: lastPostId), context, loadMore: (String id) {
                setState(() {
                  lastPostId=id;
                });
              })),
        ),
      ],
    );
  }

  Future _refreshData() async {
    print('refresh');
    setState(() {
      lastPostId = null;
    });
  }
}


