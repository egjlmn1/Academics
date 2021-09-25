import 'package:academics/errors.dart';
import 'package:academics/posts/postUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../cloudUtils.dart';
import 'folders.dart';
import 'foldersUtil.dart';

class UploadToFolders extends StatefulWidget {
  final String postId;

  const UploadToFolders({Key key, @required this.postId}) : super(key: key);

  @override
  _UploadToFoldersState createState() => _UploadToFoldersState();
}

class _UploadToFoldersState extends State<UploadToFolders> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
      future: getUserFolders(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isEmpty) {
            return _createFolders([]);
          }
          return FutureBuilder(
            future: fetchInBatches(
                Collections.userFolders, List.from(snapshot.data.map((e) => e.path))),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _createFolders(snapshot.data);
              }
              return _createFolders([]);
            },
          );
        }
        if (snapshot.hasError) {
          return errorWidget('Error fetching folders', context);
        }
        return Container();
      },
    ));
  }

  Widget _createFolders(List<DocumentSnapshot> items) {
    items.sort((a, b) => a.get('path').toString().compareTo(b.get('path')));

    var buttons = List.generate(items.length, (index) {
      Folder folder = Folder(
          path: items[index].get('path').toString(), type: FolderType.user);
      return TextButton(
        onPressed: () async {
          await uploadObject(
              Collections.userFolders,
              {
                'id': widget.postId,
              },
              doc: items[index].id,
              subCollection: Collections.posts);
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
          String id = await uploadObject(Collections.userFolders, {
            'path': path,
            'owner': FirebaseAuth.instance.currentUser.uid,
          });
          await addToObject(
              Collections.users, FirebaseAuth.instance.currentUser.uid, 'folders', id);
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
    return controller.text.trim().isEmpty? null:controller.text.trim();
  }
}

class UserFoldersPage extends StatelessWidget {
  final String folderId;

  const UserFoldersPage({Key key, this.folderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              addToObject(
                  Collections.users, await searchUser(context), 'folders', folderId);
            },
          )
        ],
      ),
      body: Container(
        child: createPostPage(
            fetchPosts(folder: Folder(path: folderId, type: FolderType.user)),
            context),
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
                onUserClick: (DocumentSnapshot user) {
                  Navigator.of(context).pop(user.id);
                },
                removeUsersCondition: (DocumentSnapshot user) {
                  return List<String>.from(user.get('folders'))
                      .contains(folderId);
                }),
          );
        });
  }
}

Future<List<DocumentSnapshot>> getKnownUsers() async {
  List<DocumentSnapshot> chatsIds = await getDocs(Collections.users,
      doc: FirebaseAuth.instance.currentUser.uid, subCollection: Collections.chat);
  List<DocumentSnapshot> chats =
      await fetchInBatches(Collections.chat, List.from(chatsIds.map((e) => e.id)));
  Set<String> usersId =
      Set.from(chats.map((e) => e.get('users')).expand((pair) => pair));
  usersId.remove(FirebaseAuth.instance.currentUser.uid);

  Future<List<DocumentSnapshot>> users =
      fetchInBatches(Collections.users, usersId.toList());
  return users;
}

class SearchUser extends StatefulWidget {
  final Future<List<DocumentSnapshot>> users;
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
                List<DocumentSnapshot> users = snapshot.data;
                users = List.from(users.where((element) => ((element
                        .get('display_name')
                        .toString()
                        .toLowerCase()
                        .startsWith(_searchPrefix.toLowerCase())) ||
                    (element
                        .get('email')
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
              if (snapshot.hasError) {}
              return Container();
            },
          ),
        ),
      ),
    ]);
  }

  Widget buildItem(DocumentSnapshot user) {
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
                  user.get('display_name'),
                  style: TextStyle(
                      color: Theme.of(context).accentColor, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.get('show_email'))
                  Text(
                    user.get('email'),
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
