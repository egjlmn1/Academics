import 'dart:async';

import 'package:academics/posts/postBuilder.dart';
import 'package:academics/posts/viewmodel.dart';
import 'package:flutter/material.dart';

import '../routes.dart';

class PostsPage extends StatefulWidget {
  PostsPage();

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  SearchPostsListViewModel viewModel;

  @override
  void initState() {
    super.initState();
    print('init posts');

    viewModel = SearchPostsListViewModel();
    viewModel.addListener(() {
      setState(() {});
    });
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (viewModel.search != '')
                  Flexible(
                    child: TextButton(
                      child: Row(
                        children: [
                          Flexible(
                              child: Text(
                            viewModel.search,
                            overflow: TextOverflow.ellipsis,
                          )),
                          Icon(Icons.close),
                        ],
                      ),
                      onPressed: () {
                        viewModel.search = '';
                      },
                    ),
                  ),
                TextButton(
                  onPressed: () async {
                    var s = await Navigator.of(context)
                        .pushNamed(Routes.postSearch);
                    print(s);
                    viewModel.search = s;
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.search),
                        Text('search'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
        Expanded(
          child: RefreshIndicator(
              onRefresh: _refreshData,
              child:
                  PostListBuilder(posts: viewModel.postsList, context: context)
                      .buildPostPage(loadMore: (String id) {
                viewModel.lastPostId = id;
              })),
        ),
      ],
    );
  }

  Future _refreshData() async {
    print('refresh');
    viewModel.lastPostId = null;
  }
}
