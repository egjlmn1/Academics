import 'package:academics/chooseFolder.dart';
import 'package:flutter/material.dart';
import 'mainPage.dart';
import 'postSearch.dart';
import 'upload.dart';

void main() {
  runApp(
    MaterialApp(
      initialRoute: '/chooseFolder',
      routes: {
        '/' : (context) => MainPage(),
        '/post_search' : (context) => PostSearch(),
        '/upload_question' : (context) => UploadPage(QuestionUploadType()),
        '/upload_file' : (context) => UploadPage(FileUploadType()),
        '/upload_poll' : (context) => UploadPage(PollUploadType()),
        '/upload_confession' : (context) => UploadPage(ConfessionUploadType()),
        '/upload_social' : (context) => UploadPage(SocialUploadType()),
        '/chooseFolder' : (context) => ChooseFolder(),

      },
      debugShowCheckedModeBanner: false,
    )
  );
}



