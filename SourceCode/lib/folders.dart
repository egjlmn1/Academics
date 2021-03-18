import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FoldersPage extends StatefulWidget {
  @override
  _FoldersPageState createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {

  List<String> folders = [
    "very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very long text",
    "2",
    "3"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (search) {
                      print('new search in folders is: $search');
                    },
                  ),
                ),
                Icon(Icons.search)
              ],
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: createFolder(index),
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createFolder(int index) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Text(
                folders[index],
                style: TextStyle(fontSize: 20),
              )
          ),
          Icon(
            Icons.folder,
            size: 30,
          ),
        ],
      ),
    );
  }
}
