import 'package:academics/errors.dart';
import 'package:academics/folders/viewModel.dart';
import 'package:academics/posts/postBuilder.dart';
import 'package:academics/user/model.dart';
import 'package:academics/user/userUtils.dart';
import 'package:flutter/material.dart';

import 'folders.dart';

class UploadToFolders extends StatefulWidget {
  final String postId;

  const UploadToFolders({Key key, @required this.postId}) : super(key: key);

  @override
  _UploadToFoldersState createState() => _UploadToFoldersState();
}

class _UploadToFoldersState extends State<UploadToFolders> {
  UserFoldersViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = UserFoldersViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
      future: viewModel.folders,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isEmpty) {
            return _createFolders([]);
          }
          return errorWidget('No folders', context);
        }
        if (snapshot.hasError) {
          return errorWidget('Error fetching folders', context);
        }
        return Container();
      },
    ));
  }

  Widget _createFolders(List<Map<String, dynamic>> items) {
    items.sort((a, b) => a['path'].compareTo(b['path']));

    var buttons = List.generate(items.length, (index) {
      Folder folder = Folder(path: items[index]['path'], type: FolderType.user);
      return TextButton(
        onPressed: () async {
          await viewModel.uploadPost(items[index]['id'], widget.postId);
          Navigator.of(context).pop();
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  folder.path,
                  style: TextStyle(
                    fontSize: 25,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(
                folder.icon(),
                size: 25,
              ),
            ],
          ),
        ),
      );
    });
    buttons.add(createFolderButton());
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 4.0,
      mainAxisSpacing: 4.0,
      children: buttons,
    );
  }

  Widget createFolderButton() {
    return TextButton(
      onPressed: () async {
        String path = await askForFolderName(context);
        if (path != null) {
          await viewModel.createFolder(path);
          setState(() {});
        }
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create new Folder',
              style: TextStyle(
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            ),
            Icon(
              Icons.add,
              size: 25,
            ),
          ],
        ),
      ),
    );
  }

  Future<String> askForFolderName(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter new folder name'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Folder name"),
              maxLength: 128,
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text('Submit'),
                onPressed: () {
                  if (controller.text.trim().isEmpty) {
                    showError('Enter folder name', context);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        });
    return controller.text.trim().isEmpty ? null : controller.text.trim();
  }
}

class UserFoldersPage extends StatelessWidget {
  final SingleUserFolderViewModel viewModel;

  const UserFoldersPage(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              String user = await searchUser(context);
              if (user != null) {
                viewModel.shareToUser(user);
              }
            },
          )
        ],
      ),
      body: Container(
        child: PostListBuilder(
                posts: viewModel.posts,
                context: context)
            .buildPostPage(),
      ),
    );
  }

  Future<String> searchUser(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Search student'),
            content: SearchUser(
                users: getKnownUsers(),
                onUserClick: (AcademicsUser user) {
                  Navigator.of(context).pop(user.id);
                },
                removeUsersCondition: (AcademicsUser user) {
                  return List<String>.from(user.folders).contains(viewModel.folderId);
                }),
          );
        });
  }
}

class SearchUser extends StatefulWidget {
  final Future<List<AcademicsUser>> users;
  final Function onUserClick;
  final Function removeUsersCondition;

  const SearchUser(
      {Key key,
      @required this.users,
      @required this.onUserClick,
      @required this.removeUsersCondition})
      : super(key: key);

  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  String _searchPrefix = '';

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 50,
        child: TextField(
          onChanged: (String text) {
            setState(() {
              _searchPrefix = text;
            });
          },
          decoration: InputDecoration(hintText: "name or email"),
        ),
      ),
      Flexible(
        child: SizedBox(
          height: double.infinity,
          width: 300,
          child: FutureBuilder(
            future: widget.users,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<AcademicsUser> users = snapshot.data;
                users = List.from(users.where((element) => ((element.displayName
                        .toString()
                        .toLowerCase()
                        .startsWith(_searchPrefix.toLowerCase())) ||
                    (element.email
                        .toString()
                        .toLowerCase()
                        .startsWith(_searchPrefix.toLowerCase())))));
                users.removeWhere(
                    (element) => widget.removeUsersCondition(element));
                if (users.isEmpty) {
                  return errorWidget('You dont know anymore users', context);
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return buildItem(users[index]);
                  },
                );
              }
              if (snapshot.hasError) {
                return errorWidget('Error fetching users', context);
              }
              return Container();
            },
          ),
        ),
      ),
    ]);
  }

  Widget buildItem(AcademicsUser user) {
    return TextButton(
      child: Row(
        children: [
          Icon(Icons.person),
          SizedBox(
            width: 20,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                      color: Theme.of(context).accentColor, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.showEmail)
                  Text(
                    user.email,
                    style: TextStyle(
                        color: Theme.of(context).accentColor, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      onPressed: () {
        setState(() {});
        widget.onUserClick(user);
      },
    );
  }
}
