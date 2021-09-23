import 'package:academics/cloudUtils.dart';
import 'package:academics/errors.dart';
import 'package:academics/posts/postUtils.dart';
import 'package:academics/user/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'folders.dart';
import 'foldersUtil.dart';

class FolderPage extends StatefulWidget {
  final String folder;

  FolderPage({this.folder});

  @override
  _FolderPageState createState() => _FolderPageState();
}

// Contains both folders? and posts
class _FolderPageState extends State<FolderPage> {
  String _path = 'root';

  TextEditingController folderController = TextEditingController();

  int _selectedPage = 0;

  @override
  void initState() {
    super.initState();
    print('init folders');
    if (widget.folder != null) {
      _path = widget.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('build folders');
    var splitted = _path.split('/');
    var paths = splitted
        .map((x) => splitted.sublist(0, splitted.indexOf(x) + 1).join('/'))
        .toList();
    return Column(
      children: [
        Row(
            children: List.generate(
                paths.length,
                (index) => Flexible(
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              _path = paths[index];
                            });
                          },
                          child: Text(paths[index].split('/').last)),
                    ))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPage = 0;
                });
              },
              child: Text('Posts'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPage = 1;
                });
              },
              child: Text('Folders'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPage = 2;
                });
              },
              child: Text('My Folders'),
            ),
          ],
        ),
        if (_selectedPage == 0)
          Expanded(
            child: RefreshIndicator(
                onRefresh: _refreshData,
                child: createPostPage(
                    fetchPosts(
                        folder: Folder(path: _path, type: FolderType.folder)),
                    context)),
          )
        else if (_selectedPage == 1)
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: folderController,
                    onChanged: (text) {print(text);setState(() {});},
                    decoration: InputDecoration(
                      hintText: 'folder name',
                    ),
                  ),
                ),
                Expanded(
                    child: createFolderList(fetchSubFolders(_path, prefix: folderController.text), (Folder folder) {
                  setState(() {
                    _path = folder.path;
                    _selectedPage = 0;
                    folderController.clear();
                  });
                }, save: (AcademicsUser user, Folder folder) async {
                  await _saveFolder(user, folder);
                  setState(() {});
                })),
              ],
            ),
          )
        else if (_selectedPage == 2)
          Expanded(child: createMyFolderList())
      ],
    );
  }

  Future _refreshData() async {
    print('refresh');
    setState(() {});
  }

  Widget createMyFolderList() {
    return FutureBuilder(
      future: getUserFolders(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isEmpty) {
            return Container();
          }
          return FutureBuilder(
            future: fetchInBatches(
                'userFolders', List.from(snapshot.data.map((e) => e.path))),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<DocumentSnapshot> items = snapshot.data;
                items.sort((a,b)=>a.get('path').toString().compareTo(b.get('path')));
                return ListView(
                  shrinkWrap: true,
                  children: List.generate(items.length, (index) {
                    return ListTile(
                        title: TextButton(
                      onPressed: () {
                        setState(() {
                          Navigator.of(context).pushNamed('/user_posts',
                              arguments: items[index].id);
                        });
                      },
                      child: Folder(
                              path: items[index].get('path'),
                              type: FolderType.user)
                          .build(),
                    ));
                  }),
                );
              } if (snapshot.hasError) {
                return errorWidget('Error fetching folders', context);
              }
              return Container();
            },
          );
        }
        return Container();
      },
    );
  }

  Future<void> _saveFolder(AcademicsUser user, Folder folder) async {
    bool isFollowing = user.following.contains(folder.path);

    if (!isFollowing) {
      isFollowing = true;
      await addToObject(Collections.users, user.id, 'following', folder.path);
    } else {
      isFollowing = false;
      await removeFromObject(Collections.users, user.id, 'following', folder.path);
    }
  }
}
