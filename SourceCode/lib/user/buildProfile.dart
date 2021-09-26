import 'package:academics/cloud/firebaseUtils.dart';
import 'package:academics/folders/folders.dart';
import 'package:academics/folders/foldersUtil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../exit.dart';
import '../routes.dart';

class BuildProfile extends StatefulWidget {
  @override
  _BuildProfileState createState() => _BuildProfileState();
}

class _BuildProfileState extends State<BuildProfile> {

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(onWillPop: () { return onWillPop(context); },
        child: SafeArea(
          child: Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  onChanged: (text) {print(text);setState(() {});},
                  decoration: InputDecoration(
                    hintText: 'department name',
                  ),
                ),
                Expanded(
                  child: createFolderList(
                      fetchSubFolders('root', prefix: controller.text, department: true),
                      (Folder folder) async {
                    await updateObject(
                        Collections.users,
                        FirebaseAuth.instance.currentUser.uid,
                        'department',
                        folder.path);
                    await addToObject(Collections.users, FirebaseAuth.instance.currentUser.uid, 'following', folder.path);
                    await updateObject(
                        Collections.users,
                        FirebaseAuth.instance.currentUser.uid,
                        'new',
                        false);
                    Navigator.of(context).pushReplacementNamed(Routes.home);
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
