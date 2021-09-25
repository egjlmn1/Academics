import 'dart:async';
import 'package:academics/folders/folders.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../folders/foldersUtil.dart';

class ChooseFolderPage extends StatelessWidget {

  final String folder;

  const ChooseFolderPage({Key key, this.folder}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(appBar: AppBar(),body: SafeArea(child: ChooseFolder(folder: folder)));
  }
}

class ChooseFolder extends StatefulWidget {
  final String folder;

  ChooseFolder({this.folder});

  @override
  _ChooseFolderState createState() => _ChooseFolderState(folder);
}

class _ChooseFolderState extends State<ChooseFolder> {
  List<String> selectedFolders = [];
  Future<List<String>> previousFolders;

  final folderTextFieldController = TextEditingController();

  _ChooseFolderState(String folder) {
    pickFolder(folder);
  }

  @override
  void initState() {
    super.initState();
    previousFolders = loadPreviousFolders();
  }

  Future<List<String>> loadPreviousFolders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> folders = prefs.getStringList('previousFolders') ?? [];
    if (folders.contains('root')) {
      folders.remove('root');
    }
    return folders;
  }

  void pickFolder(String folderPath) {
    selectedFolders = folderPath.split('/');
  }

  String get selectedFolder {
    var folder = selectedFolders.join('/');
    return folder;
  }

  Future<List<Folder>> getFolders(String prefixPath) async {
    if (prefixPath.isEmpty && (selectedFolders.length == 1)) {
      return List.from((await previousFolders).map((e) => Folder(path: e)));
    }
    return fetchSubFolders(selectedFolder, prefix: prefixPath);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
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
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text((selectedFolders[index] =='root')?'/':selectedFolders[index]),
                          if (index > 0)
                            IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.close),
                                onPressed: (() {
                                  setState(() {
                                    selectedFolders.removeRange(
                                        index, selectedFolders.length);
                                    //selectedFolders.removeAt(index);
                                  });
                                }))
                        ],
                      ),
                    );
                  }),
            ),
            TextButton(
                onPressed: (() {
                  select();
                }),
                child: Text('select')),
            Container(
              height: 30,
              child: TextField(
                controller: folderTextFieldController,
                onChanged: (text) {
                  setState(() {});
                },
                  decoration: InputDecoration(
                    hintText: 'folder name',
                  ),
              ),
            ),
            Expanded(
              child: createFolderList(getFolders(folderTextFieldController.text.trim()), (Folder folder) {
                setState(() {
                  folderTextFieldController.clear();
                  pickFolder(folder.path);
                });
              }),
            ),
          ],
        ),
      ),
    );
  }

  void select() async {
    var folder = selectedFolder;
    List<String> previous = (await previousFolders);
    if (previous.contains(folder)) {
      previous.remove(folder);
    }
    previous.insert(0, folder);
    savePreviousFolders(previous);
    Navigator.of(context).pop(folder);
  }

  void savePreviousFolders(List<String> previous) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('previousFolders', previous);
  }
}
