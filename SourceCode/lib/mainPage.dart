import 'dart:io';

import 'package:academics/folders.dart';
import 'package:academics/home.dart';
import 'package:academics/upload.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Page _selectedPage = Page.home;
  Page _previousPage = Page.home;
  List<StatefulWidget> pages = [HomePage(), FoldersPage(), null, null, null];
  OverlayEntry _uploadOverlay;


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (_uploadOverlay != null) {
          _uploadOverlay.remove();
          _uploadOverlay = null;
          return Future.value(false);
        } else {
          if (_selectedPage == Page.home) {
            return Future.value(true);
            //exit(0);
          } else {
            _onItemTapped(Page.home.index);
            return Future.value(false);
          }
        }
      },
      child: Scaffold(
        body: SafeArea(child: getPage(_selectedPage)),
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
          ],
          currentIndex: _selectedPage.index,
          selectedItemColor: Colors.amber[800],
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
        _previousPage = _selectedPage;
        _selectedPage = Page.values[index];
      });
    }
  }
  Widget getPage(Page p) {
    return pages[p.index];
    switch (p) {
      case Page.home:
        return HomePage();
      case Page.folders:
        return FoldersPage();
      case Page.upload:
        //return CreatePage(_previousPage);
        break;
      case Page.inbox:
        break;
      case Page.profile:
        return MaterialApp(

        );
      default:

    }
  }
}

enum Page {
  home,
  folders,
  upload,
  inbox,
  profile,
}

