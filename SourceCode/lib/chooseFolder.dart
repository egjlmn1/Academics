import 'package:flutter/material.dart';

class ChooseFolder extends StatefulWidget {
  @override
  _ChooseFolderState createState() => _ChooseFolderState();
}

class _ChooseFolderState extends State<ChooseFolder> {

  List<String> previousFolders = ['/Exact Science/Computer Science'];
  List<String> faculties = ['Exact Science', 'faculty2', 'faculty3'];
  List<String> showFolders;

  String currentPick = '/';

  _ChooseFolderState() {
    showFolders = previousFolders;
  }

  List<String> getFolders(prefix_path) {
    List<String> ret = [];
    for (String faculty in faculties) {
      if (faculty.startsWith(prefix_path)) {
        ret.add(faculty);
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20,),
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Colors.black12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('/'),

                      ],
                    ),
                  );
                }
              ),
            ),
            FlatButton(
              onPressed: (() {

              }),
              child: Text('select')
            ),
            Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Text(index.toString());
                }
              ),
            ),
            Container(
              height: 30,
              child: TextField(
                onChanged: (text) {
                  if (text.isEmpty) {
                    showFolders = previousFolders;
                  } else {
                    showFolders = getFolders(text);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
