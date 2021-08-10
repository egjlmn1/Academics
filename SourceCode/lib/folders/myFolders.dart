import 'package:academics/folders/folderPage.dart';
import 'package:flutter/material.dart';

import 'foldersUtil.dart';
//
// class MyFoldersPage extends StatefulWidget {
//   @override
//   _MyFoldersPageState createState() => _MyFoldersPageState();
// }
//
// class _MyFoldersPageState extends State<MyFoldersPage> {
//   bool _listView = false;
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // floatingActionButton: ElevatedButton(
//       //   onPressed: () {
//       //     setState(() {
//       //       _listView = !_listView;
//       //     });
//       //   },
//       //   child: Text('switch'),
//       // ),
//       child: Center(
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     onChanged: (search) {
//                       print('new search in folders is: $search');
//                     },
//                   ),
//                 ),
//                 Icon(Icons.search)
//               ],
//             ),
//             Row(
//               children: [],
//             ),
//             Expanded(
//               child: createListView(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget createListView() {
//     if (_listView) {
//       return ListView.builder(
//           itemCount: items.length,
//           itemBuilder: (BuildContext context, int index) {
//             return Card(
//               child: Container(
//                 child: createFolder(items[index], _listView),
//                 padding: EdgeInsets.symmetric(vertical: 1),
//
//               ),
//             );
//           });
//     } else {
//       return GridView.count(
//         crossAxisCount: 2,
//         crossAxisSpacing: 4.0,
//         mainAxisSpacing: 4.0,
//         children: List.generate(items.length, (index) {
//           return Card(
//             child: TextButton(
//               onPressed: () {
//                 //TODO BAD!
//               },
//               child: createFolder(items[index], _listView),
//             ),
//           );
//         }),
//       );
//     }
//   }
// }