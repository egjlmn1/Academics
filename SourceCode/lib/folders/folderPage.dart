import 'package:academics/errors.dart';
import 'package:academics/folders/viewModel.dart';
import 'package:academics/posts/postBuilder.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
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
  FoldersPageViewModel viewModel;
  TextEditingController folderController = TextEditingController();

  int _selectedPage = 1;

  @override
  void initState() {
    super.initState();
    print('init folders');
    if (widget.folder != null) {
      viewModel = FoldersPageViewModel(path: widget.folder);
      _selectedPage = 0;
    } else {
      viewModel = FoldersPageViewModel();
    }
    viewModel.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    //print('build folders');
    var splitted = viewModel.path.split('/');
    var paths = splitted
        .map((x) => splitted.sublist(0, splitted.indexOf(x) + 1).join('/'))
        .toList();
    return Column(
      children: [
        folderPickRow(paths, (String path) {
          viewModel.path = path;
        }),
        Container(
          color: Theme.of(context).primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  if (_selectedPage == 0) {
                    return;
                  }
                  setState(() {
                    _selectedPage = 0;
                  });
                },
                child: Text(
                  'Posts',
                  style: TextStyle(
                      decoration: (_selectedPage == 0)
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      color: Theme.of(context).accentColor,
                      fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_selectedPage == 1) {
                    return;
                  }
                  setState(() {
                    _selectedPage = 1;
                  });
                },
                child: Text(
                  'Folders',
                  style: TextStyle(
                      decoration: (_selectedPage == 1)
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      color: Theme.of(context).accentColor,
                      fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_selectedPage == 2) {
                    return;
                  }
                  setState(() {
                    _selectedPage = 2;
                  });
                },
                child: Text(
                  'My Folders',
                  style: TextStyle(
                      decoration: (_selectedPage == 2)
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      color: Theme.of(context).accentColor,
                      fontSize: 20),
                ),
              ),
            ],
          ),
        ),
        if (_selectedPage == 0)
          Expanded(
            child: RefreshIndicator(
                onRefresh: _refreshData,
                child: PostListBuilder(
                        posts: viewModel.getPosts(), context: context)
                    .buildPostPage()),
          )
        else if (_selectedPage == 1)
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: folderController,
                    onChanged: (text) {
                      print(text);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'folder name',
                    ),
                  ),
                ),
                Expanded(
                    child: createFolderList(
                        viewModel.getFolders(folderController.text.trim()),
                        (Folder folder) {
                  _selectedPage = 0;
                  folderController.clear();
                  viewModel.path = folder.path;
                }, save: viewModel.saveFolder)),
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
      future: UserFoldersViewModel().folders,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Map<String, dynamic>> items = snapshot.data;
          items.sort((a, b) =>
              a['path'].compareTo(b['path']));
          return ListView(
            shrinkWrap: true,
            children: List.generate(items.length, (index) {
              return ListTile(
                  title: TextButton(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).pushNamed(Routes.userFolder,
                            arguments:
                            SingleUserFolderViewModel(items[index]['id']));
                      });
                    },
                    child: Folder(
                        path: items[index]['path'],
                        type: FolderType.user)
                        .build(),
                  ));
            }),
          );
        }
        if (snapshot.hasError) {
          return errorWidget('Error fetching folders', context);
        }
        return Container();
      },
    );
  }


}
