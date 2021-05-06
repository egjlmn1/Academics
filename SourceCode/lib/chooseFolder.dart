import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChooseFolder extends StatefulWidget {
  @override
  _ChooseFolderState createState() => _ChooseFolderState();
}

class _ChooseFolderState extends State<ChooseFolder> {

  List<String> selectedFolders = ['/'];
  List<String> previousFolders = ['Exact Science/Computer Science', 'Exact Science/Computer Science', 'Exact Science/Computer Science', 'Exact Science/Computer Science'];
  Future<List<String>> showFolders;

  final folderTextFieldController = TextEditingController();

  _ChooseFolderState() {
    showFolders = getFolders('');
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
    return ['getting', 'folders', 'from', 'server', 'with', 'prefix', prefixPath.toLowerCase(), 'folder/folder2'];
    try {
      //server send list of string in format 'single_folder' or 'folder/sub_folder...'
      // send to the server the currently (selected folders + prefixPath)
      final response = await http.get('http://10.0.2.2:3000/chooseFolder')
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<String> folders = [];
        for (Map data in jsonDecode(response.body)) {
          folders.add(data.toString());
        }
        return folders;
      } else {
        print(response.statusCode);
        throw Exception('Failed to load folders');
      }
    } on TimeoutException {
      throw Exception('Timeout');
      //throw Exception('Academics is currently under maintenance');
    }
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
                Navigator.pop(context, getFolder());
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
}
