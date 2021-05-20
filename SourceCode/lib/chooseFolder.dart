import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseFolder extends StatefulWidget {

  String folder;

  ChooseFolder({this.folder});

  @override
  _ChooseFolderState createState() => _ChooseFolderState();
}

class _ChooseFolderState extends State<ChooseFolder> {

  List<String> selectedFolders = ['/'];
  List<String> previousFolders = ['Exact Science/Computer Science', 'Exact Science/Computer Science', 'Exact Science/Computer Science', 'Exact Science/Computer Science'];
  Future<List<String>> showFolders;

  final folderTextFieldController = TextEditingController();

  _ChooseFolderState() {
    pickFolder(widget.folder);
    showFolders = getFolders('');
  }

  Future<List<String>> getPreviousFolders() async {
    final prefs = await SharedPreferences.getInstance();
    previousFolders = prefs.getStringList('previousFolders') ?? [];
  }

  void pickFolder(String folder) {
    selectedFolders.addAll(folder.split('/'));
  }

  String getFolder() {
    var folder = selectedFolders.join('/');
    if (selectedFolders.length > 1) {
      folder = folder.substring(1);
    }
    return folder;
  }

  Future<List<String>> getFolders(String prefixPath) async {
    if (prefixPath.isEmpty && (selectedFolders.length == 1)) {
      return previousFolders;
    }
    return ['getting', 'folders', 'from', 'server', 'with', 'prefix', getFolder() + '/' + prefixPath.toLowerCase(), 'folder/folder2'];
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
                itemCount: selectedFolders.length,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(selectedFolders[index]),
                        if (index > 0) IconButton(icon: Icon(Icons.close), onPressed: (() {
                          setState(() {
                            selectedFolders.removeAt(index);
                          });
                        }))
                      ],
                    ),
                  );
                }
              ),
            ),
            TextButton(
              onPressed: (() {
                selectFolder();
              }),
              child: Text('select')
            ),
            Container(
              height: 30,
              child: TextField(
                controller: folderTextFieldController,
                onChanged: (text) {
                  setState(() {
                    showFolders = getFolders(text);
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: showFolders,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        physics: ScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: TextButton(
                              child: Text(snapshot.data[index]),
                              onPressed: (() {
                                setState(() {
                                  folderTextFieldController.clear();
                                  pickFolder(snapshot.data[index]);
                                  showFolders = getFolders('');
                                });
                              }),
                            ),
                          );
                        }
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString().substring(11)); //removes the 'Exception: ' prefix
                  }
                  return Container();
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  void selectFolder() {
    var folder = getFolder();
    previousFolders.insert(0, folder);
    savePreviousFolders();
    Navigator.pop(context, folder);
  }

  void savePreviousFolders() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('previousFolders', previousFolders);

  }
}
