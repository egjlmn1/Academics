import 'package:flutter/material.dart';
import '../routes.dart';
import 'authUtils.dart';

class SignInButton extends StatefulWidget {
  final int type;

  const SignInButton({Key key, @required this.type}) : super(key: key);

  @override
  _SignInButtonState createState() =>
      (type == 0) ? _GoogleSignInButtonState() : _EmailSignInButtonState();
}

abstract class _SignInButtonState extends State<SignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });

                print('signing in');
                await login();
                print('signed in');
                setState(() {
                  _isSigningIn = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (image() != null)
                      Image(
                        image: AssetImage(image()),
                        height: 35.0,
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        text(),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  //Future<User> getUser();

  Future<void> login();

  String image();

  String text();
}

class _GoogleSignInButtonState extends _SignInButtonState {
  @override
  Future<void> login() {
    return Authentication.signInWithGoogle(context: context);
  }

  @override
  String image() {
    return "assets/google_logo.png";
  }

  @override
  String text() {
    return 'Sign in with Google';
  }
}


class _EmailSignInButtonState extends _SignInButtonState {

  @override
  Future<void> login() async {
    await Navigator.of(context).pushNamed(Routes.emailSignIn);
  }

  @override
  String image() {
    return null;
  }

  @override
  String text() {
   return 'Sign in with email';
  }
}
