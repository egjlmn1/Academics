import 'package:academics/chat/viewModel.dart';
import 'package:academics/errors.dart';
import 'package:academics/posts/postBuilder.dart';
import 'package:academics/posts/postCloudUtils.dart';
import 'package:academics/user/userUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({Key key, this.chatId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var _users = {};

  ChatViewModel viewModel;

  TextEditingController _sendMessageController = TextEditingController();
  bool showEmoji = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    viewModel = ChatViewModel(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (showEmoji) {
              setState(() {
                showEmoji = false;
              });
            } else {
              Navigator.of(context).pop();
            }
            return Future.value(false);
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: StreamBuilder(
                    stream: viewModel.messages,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black)));
                      } else {
                        List<Map<String,dynamic>> listMessage = snapshot.data;
                        return ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(10.0),
                          itemBuilder: (context, index) =>
                              buildItem(index, listMessage[index]),
                          itemCount: listMessage.length,
                          reverse: true,
                          //controller: listScrollController,
                        );
                      }
                    },
                  ),
                ),
              ),
              bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(int index, Map<String, dynamic> item) {
    //print(doc);
    Widget username;
    if (_users.containsKey(item['user'])) {
      username = Text(_users[item['user']]);
    } else {
      username = FutureBuilder(
          future: fetchUser(item['user']),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
            } else if (snapshot.hasData) {
              _users[item['user']] = snapshot.data.displayName;
              return Text(_users[item['user']]);
            }
            return Text('Unknown User');
          });
    }
    return Align(
      alignment: (item['user'] == FirebaseAuth.instance.currentUser.uid)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
            color: (item['user'] == FirebaseAuth.instance.currentUser.uid)
                ? Colors.green
                : Theme.of(context).indicatorColor,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['user'] != FirebaseAuth.instance.currentUser.uid)
              TextButton(
                child: username,
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.userProfile, arguments: item['user']);
                },
              )
            else
              username,
            if (item['type'] == 0)
              Text(
                item['content'],
                style: TextStyle(fontSize: 20),
              )
            else
              FutureBuilder(
                future: fetchPost(item['content']),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return TextButton(
                      child: PostBuilder(context: context, post: snapshot.data)
                          .buildHintPost(),
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.postPage, arguments: snapshot.data.id);
                      },
                    );
                  } if (snapshot.hasError) {
                    return errorWidget('Post is unavailable', context);
                  }
                  return Container();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget bottomBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 60,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).indicatorColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: TextField(
                          focusNode: focusNode,
                          cursorColor: Theme.of(context).accentColor,
                          controller: _sendMessageController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type Here",
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 12),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).indicatorColor,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Icon(
                        Icons.mic,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 7),
                    IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).accentColor,
                          size: 20,
                        ),
                        onPressed: () {
                          onSendMessage(_sendMessageController.text.trim());
                        })
                  ],
                ),
              ],
            ),
          ),
        ),
        //showEmoji ? showEmojiPicker() : Container(),
      ],
    );
  }

  void onSendMessage(String content) async {
    // type: 0 = text, 1 = post
    if (content.trim() != '') {
      _sendMessageController.clear();
      viewModel.sendChatMessage(content, 0);
      //listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      //Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }
}



