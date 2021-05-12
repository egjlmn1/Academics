import 'package:academics/postUtils.dart';
import 'package:academics/schemes.dart';
import 'package:flutter/material.dart';

import 'folderUtils.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // Your posts section

  // Following section
  List<Folder> favoriteFolders = [
    Folder(path: '/Exact Science/Computer Science', type: FolderType.folder),
    Folder(path: 'Bar Ilan University', type: FolderType.university),
  ];

  var _selectedPage = 0;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person,size: 100,),
                Text('Your Name',style: TextStyle(
                  fontSize: 30,
                ),)
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                child: Text('Your Posts'),
                onPressed: () {
                  if (_selectedPage == 0) {
                    return;
                  }
                  setState(() {
                    _selectedPage = 0;
                  });
                },
              ),
              TextButton(
                child: Text('Following'),
                onPressed: () {
                  if (_selectedPage == 1) {
                    return;
                  }
                  setState(() {
                    _selectedPage = 1;
                  });
                },
              ),
              TextButton(
                child: Text('Information'),
                onPressed: () {
                  if (_selectedPage == 2) {
                    return;
                  }
                  setState(() {
                    _selectedPage = 2;
                  });
                },
              )
            ],
          ),
          if (!profileCompleted()) completeProfile(),
          createPage(),
        ],
      ),
    );
  }

  bool profileCompleted() {
    return false;
  }

  Widget completeProfile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('Your profile is 20% done'),
        TextButton(
          child: Text('continue'),
          onPressed: () {

          },
        )
      ],
    );
  }

  Widget createPage() {
    if (_selectedPage == 0) {
       // your posts
      return Expanded(
        child: fetchPosts('profile_posts'),
      );
    } else if (_selectedPage == 1) {
      // following
      return Expanded(
          child: ListView.builder(
          itemCount: favoriteFolders.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              children: [
                Icon(favoriteFolders[index].icon()),
                Text(favoriteFolders[index].name()),
              ],
            );
            }
          )
      );
    } else {
      // information
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: Yoav Naftali'),
          Text('Email: bla balsfas@gmail.com'),
          //TODO add more information
        ],
      );
    }
  }

}
