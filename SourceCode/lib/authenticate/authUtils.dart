import 'package:academics/cloud/firebaseUtils.dart';
import 'package:academics/errors.dart';
import 'package:academics/user/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../routes.dart';

class Authentication {
  static Future<FirebaseApp> initializeFirebase({
    @required BuildContext context,
  }) async {
    var firebaseInstance;
    try {
      firebaseInstance = FirebaseAuth.instance;
    } catch (e) {
      await Firebase.initializeApp();
      firebaseInstance = FirebaseAuth.instance;
    }

    User user = firebaseInstance.currentUser;

    if (user != null) {
      // User already logged in
      Navigator.of(context).pushReplacementNamed(Routes.home);
    }
    return Firebase.app();
  }

  static Future<User> signInWithGoogle({@required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print('signInWithGoogle $e');
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            print('exists');
            customSnackBar(content: e.toString());
          } else if (e.code == 'invalid-credential') {
            print('invalid');
            customSnackBar(content: e.toString());
          }
        } catch (e) {
          customSnackBar(content: e.toString());
        }
      }
    }
    login(context, user);
    return user;
  }

  static Future<bool> signOut({BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      if (context != null) showError('Error signing out. Try again.', context);
    }
    return false;
  }

  static SnackBar customSnackBar({@required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }
}

Future<void> setUpUser(User user, {String displayName}) async {
  var userDoc = await getDocSnapshot(Collections.users, user.uid);
  String username = (displayName==null)?((user.displayName==null)?'':user.displayName):displayName;
  print('users exists: ' + userDoc.exists.toString());
  if (!userDoc.exists) {
    AcademicsUser acaUser = AcademicsUser(
      disliked: [],
      displayName: username,
      admin: false,
      //unreadInbox: [],
      showEmail: true,
      liked: [],
      posts: [],
      email: user.email,
      filters: [true, true, true, true, true, true],
      following: [],
      points: 0,
      business: false,
      folders: [],
      department: null,
    );
    Map<String, dynamic> userJson = acaUser.toJson();
    userJson.addAll({'new': true});
    await uploadObject(Collections.users, userJson, id: user.uid);
  }
}

void login(BuildContext context, User user, {String displayName}) async {
  if (user == null) {
    showError('Failed to login, try again later', context);
    return;
  }
  await setUpUser(user, displayName: displayName);
  DocumentSnapshot doc = await getDocSnapshot(Collections.users, user.uid);
  if (doc.get('new')) {
    Navigator.of(context).pushReplacementNamed(Routes.buildProfile);
  } else {
    Navigator.of(context).pushReplacementNamed(Routes.home);
  }
}
