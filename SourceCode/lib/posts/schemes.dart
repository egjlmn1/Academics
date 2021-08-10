import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Post {
  // posts received from server and shown on screen
  final String id;
  final String username;
  final String folder;
  final String title;
  final String university;
  final int upVotes;
  final int downVotes;
  final List<String> tags;

  final String type;
  PostDataWidget typeData;

  Post(
      {this.id,
      this.tags,
      this.upVotes,
      this.downVotes,
      this.username,
      this.folder,
      this.title,
      this.university,
      this.type,
      this.typeData});

  static PostDataWidget getData(String type, Map<String, dynamic> data) {
    switch (type) {
      case PostType.Question:
        return QuestionDataWidget.fromJson(data);
      case PostType.File:
        return FileDataWidget.fromJson(data);
      case PostType.Poll:
        return PollDataWidget.fromJson(data);
      case PostType.Confession:
        return ConfessionDataWidget.fromJson(data);
      case PostType.Social:
        return SocialDataWidget.fromJson(data);
      default:
        print('null');
        return null;
    }
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      username: json['username'],
      folder: json['folder'],
      title: json['title'],
      university: json['university'],
      upVotes: json['up_votes'],
      downVotes: json['down_votes'],
      tags: json['tags'].cast<String>(),
      type: json['type'],
      typeData: getData(json['type'], json['typeData']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'folder': folder,
      'title': title,
      'university': university,
      'up_votes': upVotes,
      'down_votes': downVotes,
      'tags': tags,
      'type': type,
      'typeData': typeData.toJson(),
    };
  }
}

class PostType {
  static const String Question = 'Question';
  static const String File = 'File';
  static const String Poll = 'Poll';
  static const String Confession = 'Confession';
  static const String Social = 'Social';
}

abstract class PostDataWidget {
  PostDataWidget();

  Map<String, dynamic> toJson();

  Widget createWidget();
}

class QuestionDataWidget extends PostDataWidget {
  final String data;
  final String image_id;

  QuestionDataWidget({this.data, this.image_id});

  factory QuestionDataWidget.fromJson(Map<String, dynamic> json) {
    return QuestionDataWidget(
      data: json['data'],
      image_id: json['image'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'data': data, 'image': image_id};
  }

  @override
  Widget createWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Text(data),
            if (image_id != null)
              Image.network(
                image_id,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                },
              ),
          ],
        )
        //TODO add image
        );
  }
}

class FileDataWidget extends PostDataWidget {
  final String context;
  File fileData;

  FileDataWidget({this.context});

  factory FileDataWidget.fromJson(Map<String, dynamic> json) {
    return FileDataWidget(
      context: json['context'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'context': context,
      //TODO add file
    };
  }

  @override
  Widget createWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: Text(context)),
          TextButton(
            onPressed: () {
              //TODO download and open file
            },
            // get file name and preview image
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Text(
                'File',
                style: TextStyle(fontSize: 15),
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
  final Map<String, int> polls;
  bool voted;

  PollDataWidget({this.question, this.polls, this.voted});

  factory PollDataWidget.fromJson(Map<String, dynamic> json) {
    return PollDataWidget(
      question: json['question'],
      polls: json['polls'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'polls': polls,
    };
  }

  @override
  Widget createWidget() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 20),
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
    return TextButton(
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
              padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
              child: Icon(Icons.circle)),
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
          Container(
              padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
              child: Text(evaluteAt(index).toString() + '%')),
          Expanded(child: Text(polls.keys.toList()[index]))
        ],
      ),
    );
  }

  int evaluteAt(index) {
    return 100 *
        polls.values.toList()[index] ~/
        polls.values.toList().fold(0, (a, b) => a + b);
  }
}

class ConfessionDataWidget extends PostDataWidget {
  final String context;

  ConfessionDataWidget({this.context});

  factory ConfessionDataWidget.fromJson(Map<String, dynamic> json) {
    return ConfessionDataWidget(
      context: json['context'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'context': context,
    };
  }

  @override
  Widget createWidget() {
    //TODO
    return Text('test');
  }
}

class SocialDataWidget extends PostDataWidget {
  final String context;

  SocialDataWidget({this.context});

  factory SocialDataWidget.fromJson(Map<String, dynamic> json) {
    return SocialDataWidget(
      context: json['context'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'context': context,
    };
  }

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
