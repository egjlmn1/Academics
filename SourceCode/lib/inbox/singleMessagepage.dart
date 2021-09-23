import 'package:academics/posts/postBuilder.dart';
import 'package:academics/posts/postUtils.dart';
import 'package:academics/user/userUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../cloudUtils.dart';
import 'message.dart';

class SingleMessagePage extends StatelessWidget {
  final Message message;

  const SingleMessagePage({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    message.title,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  _createPostMenu(context),
                ],
              ),
              Text(
                timeToText(message.time),
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).accentColor,
                ),
              ),
              if (message.sender != null)
                FutureBuilder(
                    future: fetchUser(message.sender),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/user_profile', arguments: message.sender);
                          },
                          child: Text(
                            'sent by ${snapshot.data.displayName}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        );
                      }
                      return Container();
                    }),
              SizedBox(
                height: 10,
              ),
              Text(message.msg.replaceAll(r'\n', '\n')),
              SizedBox(
                height: 20,
              ),
              if (message.post != null)
                FutureBuilder(
                    future: fetchPost(message.post),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/post_page',
                                arguments: snapshot.data.id);
                          },
                          child:
                              PostCreator(post: snapshot.data, context: context)
                                  .buildHintPost(),
                        );
                      } else if (snapshot.hasError) {
                        return PostCreator(post: snapshot.data, context: context)
                            .buildHintPost();
                      }
                      return Container();
                    }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createPostMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).textTheme.bodyText2.color,
      ),
      onSelected: _menuActionSelect(context),
      itemBuilder: (BuildContext context) {
        return MessageChoice.values.toList().map((MessageChoice choice) {
          return PopupMenuItem<String>(
            child: Text(
              choice.toString().split('.')[1],
              style: Theme.of(context).textTheme.bodyText2,
            ),
            value: choice.toString(),
          );
        }).toList();
      },
    );
  }

  Function _menuActionSelect(BuildContext context) {
    return (String choice) {
      if (choice == MessageChoice.Delete.toString()) {
        _deleteMessage(context);
      }
    };
  }

  void _deleteMessage(BuildContext context) {
    removeFromObject(Collections.users, FirebaseAuth.instance.currentUser.uid, Collections.inbox,
        message.toJson());
    Navigator.of(context).pop();
  }
}

enum MessageChoice { Delete }
