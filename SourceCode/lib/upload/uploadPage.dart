import 'dart:io';

import 'package:academics/folders/folders.dart';
import 'package:academics/posts/postUtils.dart';
import 'package:academics/upload/uploadType.dart';
import 'package:academics/user/userUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';
import '../cloudUtils.dart';
import '../errors.dart';
import '../posts/schemes.dart';

class UploadPage extends StatefulWidget {
  final UploadType _postType;

  UploadPage(this._postType);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  Folder _folder = Folder(path: 'root');
  List<String> _tags = [];

  void postClicked() async {
    var valid = isValid();
    if (valid) {
      try {
        Post post = Post(
          username: (await fetchUser(FirebaseAuth.instance.currentUser.uid)).displayName,
          userid: FirebaseAuth.instance.currentUser.uid,
          folder: _folder.path,
          title: await widget._postType.title(),
          uploadTime: DateTime.now().millisecondsSinceEpoch,
          upVotes: 0,
          downVotes: 0,
          tags: _tags,
          type: widget._postType.type,
        );
        showError('Uploading post...', context);
        String id = await sendPost(post);
        showError('Post uploaded!', context);
        Navigator.of(context).pop(id);
      } catch(e) {
        showError('Failed to upload post', context);
      }

    } else {
      showError(widget._postType.error(), context);
    }
  }

  void chooseFolder() async {
    final result = await Navigator.of(context).pushNamed('/choose_folder', arguments: _folder.path);
    setState(() {
      _folder = result == null ? _folder : Folder(path: result);
    });
  }

  Future<String> sendPost(Post post) async {
    /**
     * create the data type of the post
     * if needs to upload to cloud storage, get the path to the file
     * returns the id of the post
     */

    DocumentReference d = FirebaseFirestore.instance.collection('posts').doc();
    String id = d.id;
    String path;
    File f = widget._postType.file();
    if (f != null) {
      String name;
      try {
        name = id + '.' + f.path.split('.').last;
      } catch (e) {
        name = id;
      }
      path = await uploadFile(f, 'postFiles/$name');
    }
    post.typeData = widget._postType.createDataObject(path);
    d.set(post.toJson());
    await addToFolder(id, _folder.path);

    await addToObject(
        Collections.users, FirebaseAuth.instance.currentUser.uid, 'posts', id);

    print('post uploaded $id');
    return id;
  }

  bool isValid() {
    return widget._postType.isValid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._postType.type),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
            child: Column(
              children: [

                widget._postType.createUploadPage(),
                Divider(
                  height: 1,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Select Folder'),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: TextButton(
                          onPressed: () {
                            chooseFolder();
                          },
                          child: Container(
                            child: Text(_folder.name()),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                ),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    height: 55,
                    child: TextFieldTags(
                      initialTags: getAutoTags(),
                      tagsStyler: TagsStyler(
                        tagTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        tagDecoration: BoxDecoration(
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        tagCancelIcon: Icon(Icons.cancel,
                            size: 18.0, color: Colors.blue[900]),
                        tagPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                      ),
                      textFieldStyler: TextFieldStyler(
                        hintText: 'Tags separated by space',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      ),
                      onTag: (tag) {
                        _tags.add(tag);
                      },
                      onDelete: (tag) {
                        _tags.remove(tag);
                      },
                    )),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: TextButton(
                    onPressed: () {
                      postClicked();
                    },
                    child: Text('Post'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> getAutoTags() {
    // return user's default tags
    return [];
  }
}

class ChooseUploadPage extends StatelessWidget {
  static List<String> options = [
    'Question',
    'File',
    'Request',
    'Poll',
    'Confession',
    'Social'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int index = 0; index < options.length; index++)
            Flexible(
              child: TextButton(
                child: Text(options[index], style: TextStyle(fontSize: 30),),
                onPressed: () {
                  Navigator.of(context).pushNamed('/upload_${options[index].toLowerCase()}');
                },
              ),
            )
        ],
      ),
    );
  }
}
