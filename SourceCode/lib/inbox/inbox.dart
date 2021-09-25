import 'package:academics/posts/postUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../chat/chatListPage.dart';
import '../errors.dart';
import 'message.dart';



class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  var _selectedPage = 0;

  var _chatPage = ChatListPage();

  Widget createMessage(Message msg) {
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all((msg.read) ? Theme.of(context).cardColor : Theme.of(context).hintColor),
      ),
      onPressed: () async {
        await readMessage(msg, FirebaseAuth.instance.currentUser.uid);
        await Navigator.of(context).pushNamed('/message_page', arguments: msg);
        setState(() {});
      },
      child: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(msg.title, style: Theme.of(context).textTheme.subtitle1),
                  Text(msg.msg.replaceAll(r'\n', '\n'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText2),
                ],
              ),
            ),
            Text(
              timeToText(msg.time),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createPage() {
    if (_selectedPage == 0) {
      // notifications
      return FutureBuilder<List<Message>>(
        future: fetchMessages(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                physics: ScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: createMessage(snapshot.data[index]),
                  );
                });
          } else if (snapshot.hasError) {
            return errorWidget('Error reading messages', context);
          }
          return Container();
        },
      );
    } else {
      // chats
      return _chatPage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                child: Text('Notifications', style: TextStyle(
                    decoration: (_selectedPage==0) ? TextDecoration.underline:TextDecoration.none,
                    color: Theme.of(context).accentColor,
                    fontSize: 20
                ),),
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
                child: Text('Chats', style: TextStyle(
                    decoration: (_selectedPage==1) ? TextDecoration.underline:TextDecoration.none,
                    color: Theme.of(context).accentColor,
                    fontSize: 20
                ),),

              ),
            ],
          ),
        ),
        Expanded(child: createPage())
      ],
    );
  }
}
