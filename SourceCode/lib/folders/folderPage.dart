import 'package:academics/events.dart';
import 'package:academics/posts/postUtils.dart';
import 'package:academics/posts/schemes.dart';
import 'package:flutter/material.dart';

import 'folders.dart';
import 'foldersUtil.dart';

class FolderPage extends StatefulWidget {

  FolderPage({EventHandler eventHandler});

  @override
  _FolderPageState createState() => _FolderPageState();
}


// Contains both folders? and posts
class _FolderPageState extends State<FolderPage> {

  String _path = 'root';
  Future<List<Folder>> _folders;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _folders = fetchFolder(_path);

    return Container(
      child: buildPage(),
    );
  }

  Widget buildPage() {
    return Column(
      children: [
        FutureBuilder<List<Folder>>(
          future: _folders,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return createPage(snapshot.data);
            } else if (snapshot.hasError) {
              return Text(snapshot.error
                  .toString()
                  .substring(11)); //removes the 'Exception: ' prefix
            }
            return Container();
          },
        ),
        Expanded(
            child: createPostPage(_path, context)
        )
      ],
    );
  }

  Widget createPage(List<Folder> folders) {
    var splitted = _path.split('\\');
    var paths = splitted.map((x)=>splitted.sublist(0,splitted.indexOf(x)+1).join('\\')).toList();
    print(paths);
    return Column(
      children: [
        Row(
          children: List.generate(paths.length, (index) =>
            Flexible(
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      _path = paths[index];
                    });
                  },
                  child: Text(paths[index].split('\\').last)
              ),
            )
          )
        ),
        ExpansionTile(
          title: Text(
            "Folders",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          children: List<Widget>.generate(
              folders.length, (index) => ListTile(title: TextButton(
            onPressed: () {
              setState(() {
                _path = folders[index].path+'\\';
              });
            },
            child: folders[index].build(),
          ))),
          initiallyExpanded: true,
        ),
      ],
    );
  }

}
