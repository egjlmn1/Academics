
import 'dart:io';

import 'package:academics/schemes.dart';
import 'package:academics/upload/uploadWidget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

abstract class UploadType {
  String type;
  List<UploadWidget> _widgets = [];

  UploadType({this.type});

  Widget createUploadPage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _widgets
      ),
    );
  }
  bool isValid();
  Map<String, String> errors();
  PostDataWidget createDataObject([data]); //only call when valid is true
  File file();
}

class QuestionUploadType extends UploadType {

  QuestionUploadType() : super(type: PostType.Question) {
    _widgets = [UploadWidget.text(), UploadWidget.image()];
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  PostDataWidget createDataObject([image_id]) {
    return QuestionDataWidget(
        data: _widgets[0].data(),
        image_id: image_id
    );
  }

  @override
  Map<String, String> errors() {
    // always valid
    return null;
  }

  @override
  File file() {
    return _widgets[1].data();
  }
}

class FileUploadType extends UploadType {

  FileUploadType() : super(type: PostType.File) {
    _widgets = [UploadWidget.text(), UploadWidget.file()];
  }

  @override
  bool isValid() {
    return file() != null;
  }

  @override
  PostDataWidget createDataObject([file_id]) {
    // TODO: implement createDataObject
    throw UnimplementedError();
  }

  @override
  Map<String, String> errors() {
    // always valid
    return null;
  }

  @override
  File file() {
    // TODO: implement file
    return _widgets[1].data();
  }
}

class PollUploadType extends UploadType {

  PollUploadType() : super(type: PostType.Poll) {
    _widgets = [UploadWidget.text(), UploadWidget.poll()];
  }

  Map<String,int> createPolls() {
    return Map<String,int>.fromIterable(_widgets[1].data(), key: (e) => e, value: (_) => 0);
  }

  @override
  bool isValid() {
    // TODO: implement isValid
    throw UnimplementedError();
  }

  @override
  PostDataWidget createDataObject([data]) {
    return PollDataWidget(
      question: _widgets[0].data(),
      polls: createPolls(),
    );
  }

  @override
  Map<String, String> errors() {
    // always valid
    return null;
  }

  @override
  File file() {
    // TODO: implement file
    throw UnimplementedError();
  }
}

class ConfessionUploadType extends UploadType {
  ConfessionUploadType() : super(type: PostType.Confession) {
    _widgets = [UploadWidget.text()];

  }

  @override
  bool isValid() {
    // TODO: implement isValid
    throw UnimplementedError();
  }

  @override
  PostDataWidget createDataObject([data]) {
    return QuestionDataWidget(
        data: _widgets[0].data(),
    );
  }

  @override
  Map<String, String> errors() {
    // always valid
    return null;
  }

  @override
  File file() {return null;}
}

class SocialUploadType extends UploadType {
  SocialUploadType() : super(type: PostType.Social) {
    _widgets = [UploadWidget.text(), UploadWidget.image()];
  }

  @override
  bool isValid() {
    // TODO: implement isValid
    throw UnimplementedError();
  }

  @override
  PostDataWidget createDataObject([image_id]) {
    return QuestionDataWidget(
        data: _widgets[0].data(),
        image_id: image_id
    );
  }

  @override
  Map<String, String> errors() {
    // always valid
    return null;
  }

  @override
  File file() {
    return _widgets[1].data();
  }
}