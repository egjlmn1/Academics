import 'dart:io';

import 'package:academics/cloud/firebaseUtils.dart';
import 'package:academics/posts/model.dart';
import 'package:academics/upload/uploadWidget.dart';
import 'package:flutter/material.dart';

abstract class UploadType {
  String type;
  List<UploadWidget> _widgets = [];

  UploadType({this.type});

  Widget createUploadPage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: _widgets),
    );
  }

  bool isValid();

  String error();

  PostDataWidget createDataObject([data]); //only call when valid is true
  Future<String> title() async {
    return _widgets[0].data();
  }
  File file();
}

class QuestionUploadType extends UploadType {
  QuestionUploadType() : super(type: PostType.Question) {
    _widgets = [UploadWidget.title('Question Title', required: true), UploadWidget.text('Body (make sure to include all the information)', required: true), UploadWidget.image()];
  }

  @override
  bool isValid() {
    return _widgets[0].data() != null && _widgets[1].data() != null;
  }

  @override
  PostDataWidget createDataObject([imageId]) {
    return QuestionDataWidget(question: _widgets[1].data(), imageId: imageId, acceptedAnswer: null, followers: []);
  }

  @override
  String error() {
    if (_widgets[0].data() == null) {
      return 'Add a title';
    }
    if (_widgets[1].data() == null) {
      return 'Add a body';
    }
    return null;
  }

  @override
  File file() {
    return _widgets[2].data();
  }
}

class FileUploadType extends UploadType {
  FileUploadType() : super(type: PostType.File) {
    _widgets = [UploadWidget.title('File Description', required: true), UploadWidget.choices(['Test','Summary', 'Analytics'], other: true, required: true), UploadWidget.file(required: true)];
  }

  @override
  bool isValid() {
    return _widgets[0].data() != null && file() != null && _widgets[1].data() != null;
  }

  @override
  PostDataWidget createDataObject([file]) {
    return FileDataWidget(fileId: file, type: _widgets[1].data());
  }

  @override
  String error() {
    if (_widgets[0].data() == null) {
      return 'Add file description';
    }
    if (file() == null) {
      return 'Upload a file';
    }
    if (_widgets[1].data() == null) {
      return 'Choose file type';
    }
    return null;
  }

  @override
  File file() {
    return _widgets[2].data();
  }
}


class RequestUploadType extends UploadType {
  RequestUploadType() : super(type: PostType.Request) {
    _widgets = [UploadWidget.title('e.g. "Answered test in cryptography 2019 Bar Ilan', required: true)];
  }

  @override
  bool isValid() {
    return _widgets[0].data().toString().isNotEmpty;
  }

  @override
  PostDataWidget createDataObject([file]) {
    return RequestDataWidget(followers: []);
  }

  @override
  String error() {
    if (_widgets[0].data() == null) {
      return 'Add requested file description';
    }
    return null;
  }

  @override
  File file() {
    return null;
  }
}


class PollUploadType extends UploadType {
  PollUploadType() : super(type: PostType.Poll) {
    _widgets = [UploadWidget.title('Poll Question', required: true), UploadWidget.poll(required: true)];
  }

  @override
  bool isValid() {
    List<String> data = _widgets[1].data();
    return _widgets[0].data()!=null && !data.contains('');

  }

  @override
  PostDataWidget createDataObject([data]) {
    return PollDataWidget(
      polls: {for (String p in _widgets[1].data()) p:0},
      voted: {},
    );
  }

  @override
  String error() {
    if (_widgets[0].data() == null) {
      return 'Add a question';
    }
    List<String> data = _widgets[1].data();
    if (data.contains('')) {
      return 'All choices must be filled';
    }
    return null;
  }

  @override
  File file() {
    return null;
  }
}

class ConfessionUploadType extends UploadType {
  ConfessionUploadType() : super(type: PostType.Confession) {
    _widgets = [UploadWidget.text('Confession', required: true)];
  }

  @override
  bool isValid() {
    return _widgets[0].data().toString().isNotEmpty;
  }

  @override
  PostDataWidget createDataObject([data]) {
    return ConfessionDataWidget(
      confession: _widgets[0].data(),
    );
  }

  @override
  Future<String> title() async {
    int num = (await getDocSnapshot('data', 'confessions')).get('number');
    updateObject('data', 'confessions', 'number', num+1);
    return '#$num';
  }

  @override
  String error() {
    if (_widgets[0].data() == null) {
      return 'Write your confession';
    }
    return null;
  }

  @override
  File file() {
    return null;
  }
}

class SocialUploadType extends UploadType {
  SocialUploadType() : super(type: PostType.Social) {
    _widgets = [UploadWidget.title('Interesting Title', required: true), UploadWidget.text('Your text (optional)'), UploadWidget.image()];
  }

  @override
  bool isValid() {
    return _widgets[0].data().toString().isNotEmpty;
  }

  @override
  PostDataWidget createDataObject([imageId]) {
    return SocialDataWidget(text: _widgets[1].data(), imageId: imageId);
  }

  @override
  String error() {
    if (_widgets[0].data() == null) {
      return 'Add a title';
    }
    return null;
  }

  @override
  File file() {
    return _widgets[2].data();
  }
}
