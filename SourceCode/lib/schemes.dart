

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowPost {
  // posts received from server and shown on screen
  final String username;
  final String folder;
  final String title;
  final String university;
  final int votes;
  final List<String> tags;

  final PostType type;
  final PostDataWidget typeData;


  ShowPost({this.tags, this.votes, this.username, this.folder, this.title, this.university, this.type, this.typeData});
}

enum PostType {
  Question,
  File,
  Poll,
  Confession,
  Social,
}

abstract class PostDataWidget {
  PostDataWidget();

  Widget createWidget();
}
class QuestionDataWidget extends PostDataWidget {
  final String data;
  final String image;
  QuestionDataWidget({this.data, this.image});

  @override
  Widget createWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(data)
    );
  }
}
class FileDataWidget extends PostDataWidget {
  final String context;

  FileDataWidget({this.context});

  @override
  Widget createWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: Text(context)
          ),
          FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.red)
            ),
            onPressed: () {
              //TODO download and open file
            },
            // get file name and preview image
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Text(
                'File',style: TextStyle(
                fontSize: 15
              ),
              ),
            ),
          ),
      ],
      ),
    );
  }
}
class PollDataWidget extends PostDataWidget {

  final String question;
  final Map<String,int> polls;
  bool voted;


  PollDataWidget({this.question, this.polls, this.voted});

  @override
  Widget createWidget() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(question),
          ),
          Container(
            child: Column(
              children: List<Widget>.generate(polls.length, (index) {
                if (voted) {
                  return yesVote(index);
                } else {
                  return noVote(index);
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget noVote(index) {
    return FlatButton(
      onPressed: () {

      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(padding: EdgeInsets.fromLTRB(0,5,5,5),child: Icon(Icons.circle)),
          Expanded(child: Text(polls.keys.toList()[index]))
        ],
      ),
    );
  }

  Widget yesVote(index) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(padding: EdgeInsets.fromLTRB(0,5,5,5),child: Text(evaluteAt(index).toString() + '%')),
          Expanded(child: Text(polls.keys.toList()[index]))
        ],
      ),
    );
  }

  int evaluteAt(index) {
    return 100 * polls.values.toList()[index] ~/ polls.values.toList().fold(0, (a, b) => a + b);
  }
}
class ConfessionDataWidget extends PostDataWidget {

  @override
  Widget createWidget() {
    //TODO
    return Text('test');
  }
}
class SocialDataWidget extends PostDataWidget {

  @override
  Widget createWidget() {
    //TODO
    return Text('test');
  }
}

class UploadPost {
  // posts uploaded from app and sent to the server
}

class UserInfo {
  // object received from server that holds information about the user
}