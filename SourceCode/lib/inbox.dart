import 'dart:async';
import 'dart:convert';

import 'package:academics/schemes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Message {
  String title;
  String msg;

  Message({this.title, this.msg});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      title: json['title'],
      msg: json['msg']
    );
  }}

Future<List<Message>> fetchMessages() async {

  return [Message(title: 'test title', msg: 'test msg')];

  try {
    final response = await http.get('http://10.0.2.2:3000/posts/home_posts')
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<Message> posts = [];
      for (Map data in jsonDecode(response.body)) {
        posts.add(Message.fromJson(data));
      }
      return posts;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      throw Exception('Failed to load posts');
    }
  } on TimeoutException {
    throw Exception('Timeout');
    //throw Exception('Academics is currently under maintenance');
  }
}

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {


  Future<List<Message>> futureMessages;
  var _selectedPage = 0;

  @override
  void initState() {
    super.initState();
    futureMessages = fetchMessages();
  }

  Widget createMessage(Message msg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.black),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Text(msg.title, style: TextStyle(
              fontWeight: FontWeight.bold,
            ),)
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Text(msg.msg)
        ),
        Divider(color: Colors.black),
      ],
    );
  }

  Widget createPage() {
    if (_selectedPage == 0) {
      // notifications
      return FutureBuilder<List<Message>>(
        future: futureMessages,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                physics: ScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: createMessage(snapshot.data[index]),
                  );
                }
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString().substring(
                11)); //removes the 'Exception: ' prefix
          }
          return Container();
        },
      );
    } else {
      // chats

    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text('Notifications', style: TextStyle(
                    fontSize: 20
                  ),),
                  onPressed: () {
                    if (_selectedPage == 0) {
                      return;
                    }
                    setState(() {
                      _selectedPage = 0;
                    });
                  },
                ),
                TextButton(
                  child: Text('Chats', style: TextStyle(
                      fontSize: 20
                  ),),
                  onPressed: () {
                    if (_selectedPage == 1) {
                      return;
                    }
                    setState(() {
                      _selectedPage = 1;
                    });
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: createPage()
          )
        ],
      ),
    );
  }
}
