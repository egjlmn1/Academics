import 'package:academics/home.dart';
import 'package:academics/profile.dart';
import 'package:academics/testing.dart';
import 'package:academics/upload/upload.dart';
import 'package:academics/inbox.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DarkTheme.dart';
import 'events.dart';
import 'folders/folderPage.dart';
import 'folders/myFolders.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Page _selectedPage = Page.home;
  List<Widget> pages;

  _HomeState() {
    EventHandler eventHandlers = EventHandler();
    pages = [
      PostsPage(eventHandler: eventHandlers,),
      FolderPage(eventHandler: eventHandlers,),
      null,
      InboxPage(),
      ProfilePage()
    ];
  }



  OverlayEntry _uploadOverlay;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return WillPopScope(
      onWillPop: () {
        if (_uploadOverlay != null) {
          _uploadOverlay.remove();
          _uploadOverlay = null;
          return Future.value(false);
        } else {
          if (_selectedPage == Page.home) {
            return Future.value(true);
          } else {
            _onItemTapped(Page.home.index);
            return Future.value(false);
          }
        }
      },
      child: Scaffold(
        body: SafeArea(child: getPage()),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
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
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
          unselectedItemColor: Colors.black12,
          selectedItemColor: Colors.amber[800],
          showUnselectedLabels: true,
          currentIndex: _selectedPage.index,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == Page.upload.index) {
      _uploadOverlay = ChooseUpload.getUploadOverlay(context);
      Overlay.of(context).insert(_uploadOverlay);
    } else {
      setState(() {
        _selectedPage = Page.values[index];
      });
    }
  }

  Widget getPage() {
    return pages[_selectedPage.index];
  }
}

enum Page {
  home,
  folders,
  upload,
  inbox,
  profile,
}