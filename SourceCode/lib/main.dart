import 'package:academics/business/switch.dart';
import 'package:academics/routes.dart';
import 'package:academics/upload/chooseFolder.dart';
import 'package:academics/cloud/firebaseUtils.dart';
import 'package:academics/inbox/singleMessagepage.dart';
import 'package:academics/pdf.dart';
import 'package:academics/posts/singlePostPage.dart';
import 'package:academics/reports/ReportsPage.dart';
import 'package:academics/user/buildProfile.dart';
import 'package:academics/user/profile.dart';
import 'package:academics/upload/choosePost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import 'authenticate/authUtils.dart';
import 'authenticate/emailSigninPage.dart';
import 'chat/chatPage.dart';
import 'folders/userFolders.dart';
import 'home.dart';

import 'DarkTheme.dart';
import 'upload/uploadType.dart';
import 'upload/uploadPage.dart';
import 'authenticate/authPage.dart';
import 'posts/postSearch.dart';

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  // runApp(TestApp());
  runApp(MyApp());
}

Future<String> fetchRoute() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (FirebaseAuth.instance.currentUser != null) {
    print('Current user: ${FirebaseAuth.instance.currentUser.uid}');
    DocumentSnapshot user = (await getDocSnapshot(
        Collections.users, FirebaseAuth.instance.currentUser.uid));
    if (!user.exists) {
      //In case user closed app right when creating an account and the document wasn't created yet
      if (await Authentication.signOut()) {
        return Routes.auth;
      } else {
        return Routes.home;
      }
    }
    //Signed in
    else if (user.get('new')) {
      return Routes.buildProfile;
    } else {
      return Routes.home;
    }
  } else {
    return Routes.auth;
  }
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    themeChangeProvider.darkTheme = true;

    getCurrentAppTheme();
  }

  void setAppDirectory() async {
    Directory baseDir = await getApplicationDocumentsDirectory();
    String dirToBeCreated = "Academics";
    String finalDir = join(baseDir.path, dirToBeCreated);
    var dir = Directory(finalDir);
    bool dirExists = await dir.exists();
    print('dir at: $finalDir');
    if (!dirExists) {
      dir.create(
          /*recursive=true*/); //pass recursive as true if directory is recursive
      print('dir created');
      (await SharedPreferences.getInstance())
          .setString('AppDirectory', finalDir);
    }
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return FutureBuilder(
      future: fetchRoute(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String initialRoute = snapshot.data;
          return ChangeNotifierProvider(
            create: (_) {
              return themeChangeProvider;
            },
            child: Consumer<DarkThemeProvider>(
              builder: (BuildContext context, value, Widget child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme:
                      Styles.themeData(themeChangeProvider.darkTheme, context),
                  initialRoute: initialRoute,
                  onGenerateRoute: (RouteSettings settings) {
                    //print('build route for ${settings.name}');
                    var routes = <String, WidgetBuilder>{
                      Routes.root: (context) => Container(),
                      Routes.home: (context) =>
                          Home(initialRoute: settings.arguments),
                      Routes.auth: (context) => AuthPage(),
                      Routes.buildProfile: (context) => BuildProfile(),
                      Routes.postPage: (context) =>
                          SinglePostPage(postId: settings.arguments),
                      Routes.messagePage: (context) =>
                          SingleMessagePage(message: settings.arguments),
                      Routes.reports: (context) => ReportsPage(),
                      Routes.userFolder: (context) =>
                          UserFoldersPage(settings.arguments),
                      Routes.userProfile: (context) =>
                          UserProfile(id: settings.arguments),
                      Routes.chat: (context) =>
                          ChatPage(chatId: settings.arguments),
                      Routes.postSearch: (context) => PostSearch(),
                      Routes.chooseFolder: (context) => ChooseFolderPage(
                            folder: settings.arguments,
                          ),
                      Routes.choosePost: (context) =>
                          ChoosePostPage(filter: settings.arguments),
                      Routes.pdf: (context) =>
                          PDFViewer(url: settings.arguments),
                      Routes.switchAccount: (context) =>
                          SwitchToBusiness(isBusiness: settings.arguments),
                      Routes.emailSignIn: (context) => EmailSignInPage(),
                      Routes.uploadQuestion: (context) =>
                          UploadPage(QuestionUploadType()),
                      Routes.uploadFile: (context) =>
                          UploadPage(FileUploadType(), folder: settings.arguments),
                      Routes.uploadRequest: (context) =>
                          UploadPage(RequestUploadType()),
                      Routes.uploadPoll: (context) =>
                          UploadPage(PollUploadType()),
                      Routes.uploadConfession: (context) =>
                          UploadPage(ConfessionUploadType()),
                      Routes.uploadSocial: (context) =>
                          UploadPage(SocialUploadType()),
                    };
                    WidgetBuilder builder = routes[settings.name];
                    return MaterialPageRoute(
                        builder: (context) => builder(context));
                  },
                );
              },
            ),
          );
        }
        return Container(
          padding: EdgeInsets.all(150),
          child: FadeInImage(
              fadeInDuration: Duration(milliseconds: 300),
              placeholder: MemoryImage(kTransparentImage),
              image: AssetImage('assets/logo.png')),
        );
      },
    );
  }
}
