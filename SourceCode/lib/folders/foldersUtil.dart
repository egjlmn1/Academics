import 'package:academics/posts/postUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'folderPage.dart';
import 'folders.dart';

//
// Widget createFolder(Folder item, isListView) {
//   if (isListView) {
//     return Container(
//       child: Row(
//         children: [
//           Icon(item.icon()),
//           Text(item.name()),
//         ],
//       ),
//     );
//   }
//   return Container(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 10),
//           child: Text(
//             item.name(),
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 25,
//             ),
//           ),
//         ),
//         Icon(
//           item.icon(),
//           size: 50,
//         )
//       ],
//     ),
//   );
// }

Future<List<Folder>> fetchFolder(folderPath ) async {
  //Widget posts = fetchPosts('posts_folders/' + folderPath, context);
  CollectionReference ref = FirebaseFirestore.instance.collection('folders');
  List<Folder> folders = (await ref.get()).docs.expand((e) => [if (e.id.startsWith(folderPath)) Folder(path: e.id)]).toList();
  return folders;
}



List<Folder> getUserFolders() {
  return [];
}