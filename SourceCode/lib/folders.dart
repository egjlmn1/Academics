import 'package:academics/postUtils.dart';
import 'package:academics/schemes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'folderUtils.dart';

class FoldersPage extends StatefulWidget {
  @override
  _FoldersPageState createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {

  List<Folder> shownFolders = [
    Folder(path: '/Exact Science/Computer Science', type: FolderType.folder),
  ];
  List<ShowPost> posts = [

  ];
  var _viewType = 0; // 0 for list view, 1 for drive like view

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (search) {
                      print('new search in folders is: $search');
                    },
                  ),
                ),
                Icon(Icons.search)
              ],
            ),
            Expanded(
              child: createListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget createListView() {
    return ListView.builder(
        itemCount: shownFolders.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: (index >= shownFolders.length) ? createFolderView(index) : createPostView(index-shownFolders.length),
          );
        }
    );
  }

  Widget createFolderView(int index) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Text(
                shownFolders[index].name(),
                style: TextStyle(fontSize: 20),
              )
          ),
          Icon(
            shownFolders[index].icon(),
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget createPostView(int index) {
    return createPost(posts[index]);
  }
}
