import 'package:academics/cloudUtils.dart';
import 'package:academics/errors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SwitchToBusiness extends StatelessWidget {
  final bool isBusiness;

  final TextEditingController _controller = TextEditingController();

  SwitchToBusiness({Key key, this.isBusiness}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: isBusiness
                        ? 'Display Name'
                        : 'Business Name',
                  )),
              OutlinedButton(
                child: Text(isBusiness
                    ? 'Switch to Student Account'
                    : 'Switch to Business Account'),
                onPressed: () async {
                  if (_controller.text.trim().isNotEmpty) {
                    await updateObject(
                        Collections.users,
                        FirebaseAuth.instance.currentUser.uid,
                        'business',
                        !isBusiness);
                    await updateObject(
                        Collections.users,
                        FirebaseAuth.instance.currentUser.uid,
                        'display_name',
                        _controller.text.trim());
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
                  } else {
                    showError('Enter ${isBusiness ? 'display' : 'business'} name', context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
