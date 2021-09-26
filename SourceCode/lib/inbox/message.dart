import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../cloud/firebaseUtils.dart';

class Message {
  String id;
  final String title;
  final String msg;
  final int time;
  final String sender;
  final String post;
  final bool read;

  Message(
      {@required this.title,
      @required this.msg,
      @required this.time,
      this.sender,
      this.post,
      this.read = false});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      title: json['title'],
      msg: json['msg'],
      time: json['time'],
      sender: json['sender'],
      post: json['post'],
      read: json['read'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'msg': msg,
      'time': time,
      'sender': sender,
      'post': post,
      'read': read,
    };
  }
}

Future<void> sendMessage(Message msg, String userId) async {
  return uploadObject(Collections.users, msg.toJson(), doc: userId, subCollection: Collections.inbox);
}

Future<List<Message>> fetchMessages() async {
  List<DocumentSnapshot> docs = await getDocs(Collections.users, doc: FirebaseAuth.instance.currentUser.uid, subCollection: Collections.inbox);
  List<Message> msgs = List<Message>.from(docs.map((e) =>decodeMessage(e)));
  msgs.sort((a, b) => b.time.compareTo(a.time));
  return msgs;
}

Future deleteMessage(String msgId) {
  return deleteObject(Collections.users, msgId, doc: FirebaseAuth.instance.currentUser.uid, subCollection: Collections.inbox);
}

Message decodeMessage(DocumentSnapshot doc) {
  Message m = Message.fromJson(doc.data());
  m.id = doc.id;
  return m;
}

Future<void> readMessage(Message msg, String user) async {
  if (msg.read) {
    return msg;
  }
  return await updateObject(Collections.users, msg.id, 'read', true, doc: user, subCollection: Collections.inbox);
}

Future<int> unreadMessages() async {
  List<Message> msgs = await fetchMessages();
  return List.from(msgs.where((element) => !element.read)).length;
}

class MessageNotifier extends StatefulWidget {
  @override
  _MessageNotifierState createState() => _MessageNotifierState();
}

class _MessageNotifierState extends State<MessageNotifier> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: unreadMessages(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != 0) {
          return Container(
              padding: EdgeInsets.all(1),
              decoration: new BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                snapshot.data.toString(),
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ));
        }
        return Container();
      },
    );
  }
}
