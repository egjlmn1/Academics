
import 'dart:io';

import 'package:academics/upload/uploadType.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';
import '../chooseFolder.dart';
import '../cloudUtils.dart';
import '../posts/schemes.dart';

class UploadPage extends StatefulWidget {

  final UploadType _postType;

  UploadPage(this._postType);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {

  final _titleController = TextEditingController();
  bool _isUniversity = false;
  String _folder = '/';
  List<String> _tags = [];

  void postClicked() {
    var valid = isValid();
    if (valid) {
      Post post = Post(
        username: 'TODO(get current username)',
        folder: _folder,
        title: _titleController.text,
        university: _isUniversity ? 'TODO(get university)' : null,
        upVotes: 0,
        downVotes: 0,
        tags: _tags,
        type: widget._postType.type,
      );
      sendPost(post);
      Navigator.pop(context);
    } else {
      showErrors();
    }
  }

  void chooseFolder() async {
    final result = await Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => ChooseFolder(folder: _folder),
      ),);
    setState(() {
      _folder = result == null ? _folder : result;
    });
  }

  Future<bool> sendPost(Post post) async {
    /**
     * create the data type of the post
     * if needs to upload to cloud storage, get the url of the file
     */
    String url;

    File f = widget._postType.file();
    if (f != null) {
       url = await uploadFile(f);
       return false;
    }
    post.typeData = widget._postType.createDataObject(url);

    var id = await uploadObject('posts', post.toJson());
    print('post uploaded $id');
    return id != null;
  }

  void showErrors() {
    // show errors
    widget._postType.errors();
  }

  bool isValid() {
    return
      !_titleController.text.isEmpty
          && widget._postType.isValid();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ScrollConfiguration(
          behavior: ScrollBehavior()
            ..buildViewportChrome(context, null, AxisDirection.down),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      BackButton(
                          onPressed: () => {
                            Navigator.pop(context)
                          },
                      ),
                      Text(widget._postType.type)
                    ],
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Title'
                      ),
                      controller: _titleController,
                    )
                  ),
                  widget._postType.createUploadPage(),
                  Divider(
                    height: 1,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Folder'),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: TextButton(
                            onPressed: () {
                              chooseFolder();
                            },
                            child: Container(
                              child: Text(_folder),
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
                    child: Row(
                      children: [
                        Text('University'),
                        Checkbox(
                            value: _isUniversity,
                            onChanged: (newValue) {
                              setState(() {
                                _isUniversity = newValue;
                              });
                            },
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
                        tagDecoration: BoxDecoration(color: Colors.blue[300], borderRadius: BorderRadius.circular(8.0), ),
                        tagCancelIcon: Icon(Icons.cancel, size: 18.0, color: Colors.blue[900]),
                        tagPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),

                      ),
                      textFieldStyler: TextFieldStyler(
                        hintText: 'Tags separated by space',
                        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),

                      ),
                      onTag: (tag) {
                        _tags.add(tag);
                      },
                      onDelete: (tag) {
                        _tags.remove(tag);
                      },

                    )
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: TextButton(
                      onPressed: () {
                        postClicked();
                      },
                      child: Text(
                          'Post'
                      ),
                    ),
                  )
                ],
              ),
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

class ChooseUpload{

  static List<String> options = ['Question', 'File', 'Poll', 'Confession', 'Social'];

  static OverlayEntry getUploadOverlay(context) {
    OverlayEntry entry;
    entry = OverlayEntry(
      opaque: false,
      maintainState: true,
      builder: (context) => Positioned(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Container(
            color: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List<Widget>.generate(options.length, (index) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width/5,
                  height: MediaQuery.of(context).size.width/5,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/upload_${options[index].toLowerCase()}');
                      entry.remove();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(backgroundColor: Colors.black, radius: 15, child: Icon(Icons.question_answer, size: 20, color: Colors.white,)),
                        Text(options[index],style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),),
                      ],
                    ),
                  ),
                );
              }),

            ),
          ),
        ),
      )
    );
    return entry;
  }
}
