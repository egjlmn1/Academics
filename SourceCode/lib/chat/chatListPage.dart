import 'package:academics/errors.dart';
import 'package:academics/folders/userFolders.dart';
import 'package:academics/posts/postUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../cloudUtils.dart';
import 'chatPage.dart';
import 'chatUtils.dart';

class ChatListPage extends StatefulWidget {
  @override
  ChatListPageState createState() {
    return new ChatListPageState();
  }
}

class ChatListPageState extends State<ChatListPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection(Collections.chat)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorWidget('Error loading chats', context);
        }
        if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black)));
        } else {
          List<String> ids = List.from(snapshot.data.docs.map((d) => d.id));
          if (ids.isEmpty) {
            return Center(
                child: Text(
              'Wow such empty',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline2,
            ));
          }
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(Collections.chat)
                  .where(FieldPath.documentId, whereIn: ids)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List listMessage = snapshot.data.docs;
                  listMessage.sort((a,b)=> b.get('time').compareTo(a.get('time')));
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      if (index == listMessage.length) {
                        return newGroup();
                      } else {
                        return buildItem(index, listMessage[index]);
                      }
                    },
                    itemCount: listMessage.length + 1,
                    //controller: listScrollController,
                  );
                }
                if (snapshot.hasError) {
                  return errorWidget('Error while fetching chats', context);
                }
                return Container();
              });
        }
      },
    );
  }

  Widget newGroup() {
    return OutlinedButton(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text('Create new group'),
            Icon(Icons.add_circle_outline),
          ],
        ),
      ),
      onPressed: () async {
        var users =  Map<String,String>();
        var controller = TextEditingController();
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Search student'),
                content: NewGroup(controller: controller, myUsers: users,),
                actions: [
                  TextButton(onPressed: () {
                    if (controller.text.isEmpty) {
                      showError('Enter group name', context);
                      return;
                    }
                    if (users.isEmpty) {
                      showError('Add members', context);
                      return;
                    }
                    createGroupChat(List<String>.from(users.keys), controller.text);
                    Navigator.of(context).pop();
                  }, child: Text('Create'))
                ],
              );
            });
        setState(() {});
      },
    );
  }

  Future<void> createGroupChat(List<String> users, String groupName) async {
    users.add(FirebaseAuth.instance.currentUser.uid);
    await createChat(users, name: groupName);
  }

  Widget buildItem(int index, DocumentSnapshot doc) {
    Map<String, dynamic> item = doc.data();
    return OutlinedButton(
      child: new Column(
        children: <Widget>[
          new Divider(
            height: 10.0,
          ),
          new ListTile(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                getUsername(doc),
                Text(
                  timeToText(item['time']),
                  style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                ),
              ],
            ),
            subtitle: new Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: new Text(
                item['message'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(color: Colors.grey, fontSize: 15.0),
              ),
            ),
          )
        ],
      ),
      onPressed: () {
        Navigator.of(context).pushNamed('/chat', arguments: doc.id);
      },
    );
  }

  Widget getUsername(DocumentSnapshot chat) {
    return FutureBuilder(
        future: chatName(chat),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data,
                style: TextStyle(fontWeight: FontWeight.bold));
          }
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          return Text('Unknown user',
              style: TextStyle(fontWeight: FontWeight.bold));
        });
  }
}

class NewGroup extends StatefulWidget {
  final Future<List<DocumentSnapshot>> users = getKnownUsers();
  final Map<String,String> myUsers;
  final TextEditingController controller;

  NewGroup({Key key, @required this.myUsers, @required this.controller}) : super(key: key);

  @override
  _NewGroupState createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            height: 40,
            width: 300,
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: 'group name',
              ),
              maxLength: 64,
            ),
          ),
          Container(
            height: 40,
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.myUsers.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Text(List.from(widget.myUsers.values)[index]),
                    IconButton(onPressed: () {
                      setState(() {
                        widget.myUsers.remove(List.from(widget.myUsers.keys)[index]);
                      });
                    }, icon: Icon(Icons.close))
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: SearchUser(
                users: widget.users,
                onUserClick: (DocumentSnapshot user) {
                  setState(() {
                    widget.myUsers.addAll({user.id: user.get('display_name')});
                  });
                },
                removeUsersCondition: (DocumentSnapshot user) {
                  return widget.myUsers.containsKey(user.id);
                }),
          ),
        ],
      ),
    );
  }
}
