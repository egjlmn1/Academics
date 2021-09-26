import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post {
  // posts received from server and shown on screen
  final String id;
  final String username;
  final String userid;
  final int uploadTime;
  final String folder;
  final String title;
  final int upVotes;
  final int downVotes;
  final List<String> tags;

  final String type;
  PostDataWidget typeData;

  Post(
      {this.id,
      @required this.tags,
      @required this.upVotes,
      @required this.downVotes,
      @required this.username,
      @required this.userid,
      @required this.uploadTime,
      @required this.folder,
      @required this.title,
      @required this.type,
      this.typeData});

  static PostDataWidget getData(String type, Map<String, dynamic> data) {
    switch (type) {
      case PostType.Question:
        return QuestionDataWidget.fromJson(data);
      case PostType.File:
        return FileDataWidget.fromJson(data);
      case PostType.Request:
        return RequestDataWidget.fromJson(data);
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
      userid: json['userid'],
      folder: json['folder'],
      uploadTime: json['uploadTime'],
      title: json['title'],
      upVotes: json['up_votes'],
      downVotes: json['down_votes'],
      tags: json['tags'].cast<String>(),
      type: json['type'],
      typeData: getData(json['type'], json['typeData']),
    );
  }

  factory Post.decode(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data();
    data.addAll({'id': doc.id});
    return Post.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'userid': userid,
      'uploadTime': uploadTime,
      'folder': folder,
      'title': title,
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
  static const String Request = 'Request';
  static const String Poll = 'Poll';
  static const String Confession = 'Confession';
  static const String Social = 'Social';

  static const List<String> types = [
    Question,
    File,
    Request,
    Poll,
    Confession,
    Social
  ];

  static List<String> filtered(List<bool> filter) {
    return [
      for (int i = 0; i < types.length; i++)
        if (filter[i]) types[i]
    ];
  }
}

abstract class PostDataWidget {
  PostDataWidget();

  Map<String, dynamic> toJson();

  String file();

  List<String> getFollowers();
}

class QuestionDataWidget extends PostDataWidget {
  final String question;
  final String imageId;
  final String acceptedAnswer;
  final List<String> followers;

  QuestionDataWidget(
      {@required this.question,
      this.imageId,
      @required this.followers,
      @required this.acceptedAnswer});

  factory QuestionDataWidget.fromJson(Map<String, dynamic> json) {
    return QuestionDataWidget(
      question: json['question'],
      imageId: json['image'],
      acceptedAnswer: json['accepted_answer'],
      followers: List<String>.from(json['followers']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'image': imageId,
      'accepted_answer': acceptedAnswer,
      'followers': followers
    };
  }

  @override
  String file() {
    return imageId;
  }

  @override
  List<String> getFollowers() {
    return followers;
  }
}

class FileDataWidget extends PostDataWidget {
  final String type;
  final String fileId;

  FileDataWidget({@required this.fileId, @required this.type});

  factory FileDataWidget.fromJson(Map<String, dynamic> json) {
    return FileDataWidget(
      fileId: json['file'],
      type: json['type'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'file': fileId, 'type': type};
  }

  @override
  String file() {
    return fileId;
  }

  @override
  List<String> getFollowers() {
    return null;
  }
}

class RequestDataWidget extends PostDataWidget {
  final List<String> followers;

  RequestDataWidget({@required this.followers});

  factory RequestDataWidget.fromJson(Map<String, dynamic> json) {
    return RequestDataWidget(
      followers: List<String>.from(json['followers']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'followers': followers};
  }

  @override
  String file() {
    return null;
  }

  @override
  List<String> getFollowers() {
    return followers;
  }
}

class PollDataWidget extends PostDataWidget {
  final Map<String, int> polls;
  final Map<String, int> voted;

  PollDataWidget({@required this.polls, @required this.voted});

  factory PollDataWidget.fromJson(Map<String, dynamic> json) {
    var data = PollDataWidget(
      polls: {
        for (var choice in json['polls'].keys) choice: json['polls'][choice]
      },
      voted: {
        for (var choice in json['voted'].keys) choice: json['polls'][choice]
      },
    );
    return data;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'polls': polls,
      'voted': voted,
    };
  }

  @override
  String file() {
    return null;
  }

  @override
  List<String> getFollowers() {
    return null;
  }
}

class ConfessionDataWidget extends PostDataWidget {
  final String confession;

  ConfessionDataWidget({this.confession});

  factory ConfessionDataWidget.fromJson(Map<String, dynamic> json) {
    return ConfessionDataWidget(
      confession: json['confession'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'confession': confession,
    };
  }

  @override
  String file() {
    return null;
  }

  @override
  List<String> getFollowers() {
    return null;
  }
}

class SocialDataWidget extends PostDataWidget {
  final String text;
  final String imageId;

  SocialDataWidget({this.text, this.imageId});

  factory SocialDataWidget.fromJson(Map<String, dynamic> json) {
    return SocialDataWidget(
      text: json['text'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }

  @override
  String file() {
    return imageId;
  }

  @override
  List<String> getFollowers() {
    return null;
  }
}
