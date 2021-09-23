import 'package:academics/DarkTheme.dart';
import 'package:academics/posts/postsPage.dart';
import 'package:academics/user/profile.dart';
import 'package:academics/upload/uploadPage.dart';
import 'package:academics/inbox/inbox.dart';
import 'package:academics/user/user.dart';
import 'package:academics/user/userUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authenticate/authUtils.dart';
import 'business/bestUsers.dart';
import 'exit.dart';
import 'filter.dart';
import 'folders/folderPage.dart';
import 'inbox/message.dart';

class Home extends StatefulWidget {
  final Map<String, String> initialRoute;

  const Home({Key key, this.initialRoute}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Page _selectedPage = Page.home;
  AcademicsUser user;

  //List<Widget> pages;

  @override
  void initState() {
    super.initState();
    print('init home');

    if (widget.initialRoute != null) {
      if (widget.initialRoute.containsKey('folder')) {
        _selectedPage = Page.folders;
      }
      if (widget.initialRoute.containsKey('inbox')) {
        _selectedPage = Page.inbox;
      }
    }
  }

  List<bool> _getFilters() {
    if (user == null) {
      return [true, true, true, true, true, true];
    }
    return user.filters;
  }

  @override
  Widget build(BuildContext context) {
    //print('build home');
    return FutureBuilder(
        future: fetchUser(FirebaseAuth.instance.currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data;
          }
          return Scaffold(
            appBar: AppBar(),
            drawer: Drawer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: 200,
                    color: Theme.of(context).primaryColor,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        child: Text('Filter posts'),
                        onPressed: () async {
                          var filter = _getFilters();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                ChooseFilter(initialFilter: filter),
                          );
                        },
                      ),
                      if (user != null)
                        TextButton(
                          child: Text(
                              'Switch to ${user.business ? 'student' : 'business'} account'),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/switch', arguments: user.business);
                          },
                        ),
                      FutureBuilder(
                          future:
                              fetchUser(FirebaseAuth.instance.currentUser.uid),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Container();
                            }
                            if (snapshot.hasData) {
                              if (snapshot.data.admin) {
                                return TextButton(
                                  child: Text('Reports page'),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/reports');
                                  },
                                );
                              }
                            }
                            return Container();
                          })
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          await Authentication.signOut(context: context);
                          Navigator.of(context).pushReplacementNamed('/auth');
                        },
                        child: Text('Logout'),
                      ),
                      TextButton(
                          onPressed: () {
                            var darkThemeProvider =
                                Provider.of<DarkThemeProvider>(context,
                                    listen: false);
                            darkThemeProvider.darkTheme =
                                !darkThemeProvider.darkTheme;
                          },
                          child: Text('theme'))
                    ],
                  )
                ],
              ),
            ),
            body: WillPopScope(onWillPop: () { return onWillPop(context); },
            child: SafeArea(child: getPage())),
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder),
                  label: 'Folders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.upload_rounded),
                  label: 'Upload',
                ),
                createInboxItem('Inbox', Icons.inbox),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
                if ((user != null) && user.business)
                  BottomNavigationBarItem(
                    icon: Icon(Icons.supervised_user_circle),
                    label: 'Users',
                  ),
              ],
              unselectedItemColor: Theme.of(context).disabledColor,
              selectedItemColor: Colors.amber[800],
              showUnselectedLabels: true,
              currentIndex: _selectedPage.index,
              onTap: _onItemTapped,
            ),
          );
        });
  }

  BottomNavigationBarItem createInboxItem(String label, IconData icon) {
    return BottomNavigationBarItem(
      icon: new Stack(
        children: <Widget>[
          Icon(icon),
          Positioned(
            right: 0,
            child: MessageNotifier(),
          )
        ],
      ),
      label: label,
    );
  }

  void _onItemTapped(int index) {
    // if (index == Page.upload.index) {
    //   _uploadOverlay = ChooseUpload.getUploadOverlay(context);
    //   Overlay.of(context).insert(_uploadOverlay);
    // } else {
    setState(() {
      _selectedPage = Page.values[index];
    });
    //}
  }

  Widget getPage() {
    switch (_selectedPage) {
      case Page.home:
        return PostsPage();
      case Page.folders:
        if (widget.initialRoute != null) {
          if (widget.initialRoute.containsKey('folder')) {
            String folder = widget.initialRoute['folder'];
            widget.initialRoute.remove('folder');
            return FolderPage(folder: folder);
          }
        }
        return FolderPage();
      case Page.upload:
        return ChooseUploadPage();
      case Page.inbox:
        return InboxPage();
      case Page.profile:
        return ProfilePage(id: FirebaseAuth.instance.currentUser.uid);
      case Page.users:
        return BestUsersPage();
      default:
        return Container();
    }
    //return pages[_selectedPage.index];
  }
}

enum Page {
  home,
  folders,
  upload,
  inbox,
  profile,
  users,
}
