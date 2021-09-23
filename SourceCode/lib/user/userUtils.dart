import 'package:academics/user/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../cloudUtils.dart';

AcademicsUser decodeUser(data) {
  Map m = data.data();
  m['id'] = data.id;
  return AcademicsUser.fromJson(m);
}

Future<AcademicsUser> fetchUser(String id) async {
  AcademicsUser user = decodeUser(await getDocSnapshot(Collections.users, id));
  return user;
}

Future<List<AcademicsUser>> fetchUsers(String folder) async {
  var docs = (await FirebaseFirestore.instance
          .collection(Collections.users)
          .where('following', arrayContains: folder)
          .where('business', isEqualTo: false)
          .orderBy('points', descending: true)
          .get())
      .docs;
  return List.from(docs.map((e) => decodeUser(e)));
}

Widget createUserPage(Future<List<AcademicsUser>> users, BuildContext context) {
  return FutureBuilder(
    future: users,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        List<AcademicsUser> users = snapshot.data;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            return TextButton(
              child: Row(
                children: [
                  Text(users[index].points.toString()),
                  Icon(Icons.fiber_manual_record),
                  Text(users[index].displayName),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/user_profile', arguments: users[index].id);
              },
            );
          },
        );
      }
      if (snapshot.hasError) {
        print(snapshot.error);
      }
      return Container();
    },
  );
}
