import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../errors.dart';
import 'authUtils.dart';

class EmailSignInPage extends StatefulWidget {
  @override
  _EmailSignInPageState createState() => _EmailSignInPageState();
}

class _EmailSignInPageState extends State<EmailSignInPage> {
  int _currentPage = 0;
  bool _isSigningIn = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/start_background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: Text('Register'),
                    onPressed: () {
                      setState(() {
                        _currentPage = 0;
                      });
                    },
                  ),
                  TextButton(
                    child: Text('Login'),
                    onPressed: () {
                      setState(() {
                        _currentPage = 1;
                      });
                    },
                  ),
                ],
              ),
              (_currentPage == 0)
                  ? buildPage(
                      FirebaseAuth.instance.createUserWithEmailAndPassword,
                      register: true)
                  : buildPage(FirebaseAuth.instance.signInWithEmailAndPassword,
                      register: false)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPage(Function method, {@required bool register}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'email',
            ),
          ),
          if (register)
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'display name',
              ),
            ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              hintText: 'password',
            ),
          ),
          _isSigningIn
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
              :TextButton(
              onPressed: () async {

                String email = emailController.text.trim();
                String password = passwordController.text.trim();
                String name = nameController.text.trim();

                if (email.isEmpty) {
                  showError('email is empty', context);
                  return;
                }
                if (register && name.isEmpty) {
                  showError('password is empty', context);
                  return;
                }
                if (password.isEmpty) {
                  showError('password is empty', context);
                  return;
                }

                setState(() {
                  _isSigningIn = true;
                });
                User user;
                try {
                  user = (await method(
                          email: email,
                          password: password))
                      .user;
                } catch (e) {
                  showError(e.code, context);
                  setState(() {
                    _isSigningIn = false;
                  });
                  return;
                }
                login(context, user, displayName: (register)?name:null);
              },
              child: Text(register ? 'Register' : 'Login')),
        ],
      ),
    );
  }
}
