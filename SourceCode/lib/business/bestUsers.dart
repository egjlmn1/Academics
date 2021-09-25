import 'package:academics/folders/folders.dart';
import 'package:academics/folders/foldersUtil.dart';
import 'package:academics/user/userUtils.dart';
import 'package:flutter/material.dart';

class BestUsersPage extends StatefulWidget {

  final String folder;

  const BestUsersPage({Key key, this.folder}) : super(key: key);

  @override
  _BestUsersPageState createState() => _BestUsersPageState();
}

class _BestUsersPageState extends State<BestUsersPage> {
  String _path = 'root';

  int _selectedPage = 1;


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
        folderPickRow(paths, (String path) {
          setState(() {
            _path = path;
          });
        }),
        Container(
          color: Theme.of(context).primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  if (_selectedPage == 0) {
                    return;
                  }
                  setState(() {
                    _selectedPage = 0;
                  });
                },
                child: Text('Users', style: TextStyle(
                    decoration: (_selectedPage==0) ? TextDecoration.underline:TextDecoration.none,
                    color: Theme.of(context).accentColor,
                    fontSize: 20
                ),),
              ),
              TextButton(
                onPressed: () {
                  if (_selectedPage == 1) {
                    return;
                  }
                  setState(() {
                    _selectedPage = 1;
                  });
                },
                child: Text('Folders', style: TextStyle(
                    decoration: (_selectedPage==1) ? TextDecoration.underline:TextDecoration.none,
                    color: Theme.of(context).accentColor,
                    fontSize: 20
                ),),

              ),
            ],
          ),
        ),
        if (_selectedPage == 0)
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
                _selectedPage = 0;
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
