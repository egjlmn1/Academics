import 'package:academics/cloud/httpUtils.dart';
import 'package:academics/user/model.dart';
import 'package:academics/user/userUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../errors.dart';
import 'folders.dart';

Future<List<Folder>> fetchSubFolders(String folderPath, {bool department = false, String prefix = ''}) async {
  List<Folder> folders = await fetchHttpFolders(prefix, department: department, folder: folderPath);
  return folders;
}

Future<List<Folder>> getUserFolders() async {
  try {
    AcademicsUser user = await fetchUser(FirebaseAuth.instance.currentUser.uid);
    return List<Folder>.from(
        user.folders.map((e) => Folder(path: e, type: FolderType.user)));
  } catch (e) {
    print('getUserFolders $e');
    return [];
  }
}

Widget createFolderList(Future<List<Folder>> folders, Function onFolderPress,
    {Function(AcademicsUser, Folder) save}) {
  return FutureBuilder(
    future: Future.wait([
      folders,
      if (save != null) fetchUser(FirebaseAuth.instance.currentUser.uid),
    ]),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        print('createFolderList ${snapshot.error}');
        return errorWidget('An error while fetching folders', context);
      }
      if (snapshot.hasData) {
        List<Folder> folders = snapshot.data[0];
        AcademicsUser user;
        if (save != null) user = snapshot.data[1];
        return ListView(
          shrinkWrap: true,
          children: List.generate(folders.length, (index) {
            return ListTile(
                title: TextButton(
              onPressed: () {
                onFolderPress(folders[index]);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: folders[index].build()),
                  if (save != null)
                    IconButton(
                        onPressed: () async {
                          save(user, folders[index]);
                        },
                        icon: Icon(user.following.contains(folders[index].path)
                            ? Icons.bookmark
                            : Icons.bookmark_border))
                ],
              ),
            ));
          }),
        );
      }
      return Container();
    },
  );
}

Widget folderPickRow(List<String> paths, Function(String) onClick) {
  return Row(
      children: List.generate(
          paths.length,
              (index) => Flexible(
            child: TextButton(
                onPressed: () {
                  onClick(paths[index]);
                },
                child: Text((paths[index].split('/').last=='root')?'/':paths[index].split('/').last)),
          )));
}