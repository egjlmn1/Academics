import 'package:academics/folders/folders.dart';
import 'package:academics/folders/foldersUtil.dart';
import 'package:academics/user/userUtils.dart';
import 'package:flutter/material.dart';

import '../errors.dart';

class BestUsersPage extends StatefulWidget {

  final String folder;

  const BestUsersPage({Key key, this.folder}) : super(key: key);

  @override
  _BestUsersPageState createState() => _BestUsersPageState();
}

class _BestUsersPageState extends State<BestUsersPage> {
  String _path = 'root';

  int _currentPage = 1;


  @override
  void initState() {
    super.initState();
    print('init folders');
    if (widget.folder != null) {
      _path = widget.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('build folders');
    var splitted = _path.split('/');
    var paths = splitted
        .map((x) => splitted.sublist(0, splitted.indexOf(x) + 1).join('/'))
        .toList();
    return Column(
      children: [
        Row(
            children: List.generate(
                paths.length,
                    (index) => Flexible(
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          _path = paths[index];
                        });
                      },
                      child: Text(paths[index].split('/').last)),
                ))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                if (_path != 'root') {
                  setState(() {
                    _currentPage = 0;
                  });
                } else {
                  showError('Pick folder', context);
                }
              },
              child: Text('Users'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentPage = 1;
                });
              },
              child: Text('Folders'),
            )
          ],
        ),
        if (_currentPage == 0)
          Expanded(
            child: RefreshIndicator(
                onRefresh: _refreshData,
                child: createUserPage(fetchUsers(_path), context)),
          )
        else
          Expanded(
            child: createFolderList(fetchSubFolders(_path), (Folder folder) {
              setState(() {
                _path = folder.path;
                _currentPage = 0;
              });
            }),
          )

      ],
    );
  }

  Future _refreshData() async {
    print('refresh');
    setState(() {});
  }
}
