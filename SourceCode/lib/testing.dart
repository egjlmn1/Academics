import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  var l = [1,2,3,4,5,6];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Navigator(
          pages: [
            for (var x in l)
              MaterialPage(
                child: Scaffold(
                  body: Center(child: Text('main'+x.toString())),
                ),
                key: ValueKey(x),
              )
          ],
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }
            setState(() {
              l.remove(l.last);
            });
            return true;
          },
    )
    );
  }

}



class TestStateful extends StatefulWidget {
  @override
  _TestStatefulState createState() => _TestStatefulState();
}

class _TestStatefulState extends State<TestStateful> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  // FirebaseUser _user;
  // String _error = '';
  //
  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //       appBar: AppBar(
  //         title: const Text('Firebase Auth UI Demo'),
  //       ),
  //       body: Center(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             _getMessage(),
  //             Container(
  //               margin: EdgeInsets.only(top: 10, bottom: 10),
  //               child: RaisedButton(
  //                 child: Text(_user != null ? 'Logout' : 'Login'),
  //                 onPressed: _onActionTapped,
  //               ),
  //             ),
  //             _getErrorText(),
  //             _user != null
  //                 ? FlatButton(
  //               child: Text('Delete'),
  //               textColor: Colors.red,
  //               onPressed: () => _deleteUser(),
  //             )
  //                 : Container()
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _getMessage() {
  //   if (_user != null) {
  //     return Text(
  //       'Logged in user is: ${_user.displayName ?? ''}',
  //       style: TextStyle(
  //         fontSize: 16,
  //       ),
  //     );
  //   } else {
  //     return Text(
  //       'Tap the below button to Login',
  //       style: TextStyle(
  //         fontSize: 16,
  //       ),
  //     );
  //   }
  // }
  //
  // Widget _getErrorText() {
  //   if (_error?.isNotEmpty == true) {
  //     return Text(
  //       _error,
  //       style: TextStyle(
  //         color: Colors.redAccent,
  //         fontSize: 16,
  //       ),
  //     );
  //   } else {
  //     return Container();
  //   }
  // }
  //
  // void _deleteUser() async {
  //   final result = await FirebaseAuthUi.instance().delete();
  //   if (result) {
  //     setState(() {
  //       _user = null;
  //     });
  //   }
  // }
  //
  // void _onActionTapped() {
  //   print('test');
  //   if (_user == null) {
  //     // User is null, initiate auth
  //     FirebaseAuthUi.instance().launchAuth([
  //       AuthProvider.google(),
  //       // Google ,facebook, twitter and phone auth providers are commented because this example
  //       // isn't configured to enable them. Please follow the README and uncomment
  //       // them if you want to integrate them in your project.
  //
  //       // AuthProvider.google(),
  //       // AuthProvider.facebook(),
  //       // AuthProvider.twitter(),
  //       // AuthProvider.phone(),
  //     ]).then((firebaseUser) {
  //       setState(() {
  //         _error = "";
  //         _user = firebaseUser;
  //       });
  //     }).catchError((error) {
  //       if (error is PlatformException) {
  //         setState(() {
  //           if (error.code == FirebaseAuthUi.kUserCancelledError) {
  //             _error = "User cancelled login";
  //           } else {
  //             _error = error.message ?? "Unknown error!";
  //           }
  //         });
  //       }
  //     });
  //   } else {
  //     // User is already logged in, logout!
  //     _logout();
  //   }
  // }
  //
  // void _logout() async {
  //   await FirebaseAuthUi.instance().logout();
  //   setState(() {
  //     _user = null;
  //   });
  // }
}



