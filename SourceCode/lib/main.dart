import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mainPage.dart';

import 'DarkTheme.dart';
import 'upload/uploadType.dart';
import 'upload/upload.dart';
import 'authenticate/authPage.dart';
import 'postSearch.dart';
import 'testing.dart';

void main() async {
  // runApp(TestApp());

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final user = await FirebaseAuth.instance.currentUser;
  if (user != null) {
    //Signed in
    runApp(MyApp('/home'));
  } else {
    runApp(MyApp('/auth'));
  }
}

class MyApp extends StatefulWidget {

  var initialRoute;

  MyApp(String route) {initialRoute = route;}

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
    await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {

    return
      ChangeNotifierProvider(
        create: (_) {
          return themeChangeProvider;
        },
        child: Consumer<DarkThemeProvider>(
          builder: (BuildContext context, value, Widget child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: Styles.themeData(themeChangeProvider.darkTheme, context),
              initialRoute: widget.initialRoute,
              routes: {
                '/home': (context) => Home(),
                '/auth': (context) => AuthPage(),
                '/post_search': (context) => PostSearch(), //TODO want to remove from navigation and simply add it like the bottom navigation bar items

                //TODO Might remove if going to change the upload page
                '/upload_question': (context) => UploadPage(QuestionUploadType()),
                '/upload_file': (context) => UploadPage(FileUploadType()),
                '/upload_poll': (context) => UploadPage(PollUploadType()),
                '/upload_confession': (context) => UploadPage(ConfessionUploadType()),
                '/upload_social': (context) => UploadPage(SocialUploadType()),
              },
            );
          },
        ),);
  }
}


