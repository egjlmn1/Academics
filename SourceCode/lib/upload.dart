import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:textfield_tags/textfield_tags.dart';
import 'schemes.dart';


class UploadPage extends StatefulWidget {

  final UploadType _postType;

  UploadPage(this._postType);

  @override
  _UploadPageState createState() => _UploadPageState(_postType);
}

class _UploadPageState extends State<UploadPage> {

  final _titleController = TextEditingController();
  bool _isUniversity = false;
  String _folder = '/';
  List<String> _tags = [];

  final UploadType _postType;

  _UploadPageState(this._postType);


  void postClicked() {
    if (isValid()) {
      ShowPost post = ShowPost(
        title: _titleController.text,
        folder: 'TODO(get folder)',
        username: 'TODO(get current username)',
        university: 'TODO(get university or null if not checked)',
        type: _postType.type,
        typeData: _postType.createDataObject(),
        tags: _tags,
      );
    } else {
      showErrors();
    }
  }

  void showErrors() {
    // show errors
    _postType.showErrors();
  }

  bool isValid() {
    return
      _titleController.text.isEmpty
          && _postType.isValid();
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
                      FlatButton(
                          onPressed: () => {
                            Navigator.pop(context)
                          },
                          child: Icon(Icons.arrow_back)
                      ),
                      Text('question')
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
                  _postType.createUploadPage(),
                  Divider(
                    color: Colors.black,
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
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/chooseFolder');
                            },
                            child: Container(
                              child: Text(_folder),
                            ),
                            color: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.black),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    height: 1,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Text('University'),
                        Checkbox(
                            value: false,
                            onChanged: (newValue) {
                              _isUniversity = newValue;
                            },
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    height: 1,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    height: 55,
                    child: TextFieldTags(
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
                    child: FlatButton(
                      onPressed: () {
                        postClicked();
                      },
                      child: Text(
                          'Post'
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.black)
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
}


abstract class UploadType {
  final PostType type;

  UploadType(this.type);

  Widget createUploadPage();
  bool isValid();
  void showErrors();
  PostDataWidget createDataObject();
}

class QuestionUploadType extends UploadType {
  QuestionUploadType() : super(PostType.Question);

  @override
  Widget createUploadPage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: TextField(
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            hintText: "Your text (optional)"
        ),
      ),
    );
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  PostDataWidget createDataObject() {
    return QuestionDataWidget(
        data: 'TODO(get text)'
    );
  }

  @override
  void showErrors() {
    // always valid
  }
}

class FileUploadType extends UploadType {
  FileUploadType() : super(PostType.File);

  @override
  Widget createUploadPage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "File description (optional)"
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: FlatButton(
              onPressed: () {

              },
              child: Text(
                'Upload'
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.red)
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  bool isValid() {
    // TODO: implement isValid
    throw UnimplementedError();
  }

  @override
  PostDataWidget createDataObject() {
    // TODO: implement createDataObject
    throw UnimplementedError();
  }

  @override
  void showErrors() {
    // TODO: implement showErrors
  }
}

class PollUploadType extends UploadType {
  PollUploadType() : super(PostType.Poll);

  @override
  Widget createUploadPage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: TextField(
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            hintText: "Your text (optional)"
        ),
      ),
    );
  }

  @override
  bool isValid() {
    // TODO: implement isValid
    throw UnimplementedError();
  }

  @override
  PostDataWidget createDataObject() {
    // TODO: implement createDataObject
    throw UnimplementedError();
  }

  @override
  void showErrors() {
    // TODO: implement showErrors
  }
}

class ConfessionUploadType extends UploadType {
  ConfessionUploadType() : super(PostType.Confession);

  @override
  Widget createUploadPage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: TextField(
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            hintText: "Your text (optional)"
        ),
      ),
    );
  }

  @override
  bool isValid() {
    // TODO: implement isValid
    throw UnimplementedError();
  }

  @override
  PostDataWidget createDataObject() {
    // TODO: implement createDataObject
    throw UnimplementedError();
  }

  @override
  void showErrors() {
    // TODO: implement showErrors
  }
}

class SocialUploadType extends UploadType {
  SocialUploadType() : super(PostType.Social);

  @override
  Widget createUploadPage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: TextField(
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            hintText: "Your text (optional)"
        ),
      ),
    );
  }

  @override
  bool isValid() {
    // TODO: implement isValid
    throw UnimplementedError();
  }

  @override
  PostDataWidget createDataObject() {
    // TODO: implement createDataObject
    throw UnimplementedError();
  }

  @override
  void showErrors() {
    // TODO: implement showErrors
  }
}

class ChooseUpload{

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
              children: [

                SizedBox(
                  width: MediaQuery.of(context).size.width/5,
                  height: MediaQuery.of(context).size.width/5,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/upload_question');
                      entry.remove();
                      },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.question_answer, size: 40,),
                        Text('Question',
                          style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width/5,
                  height: MediaQuery.of(context).size.width/5,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/upload_file');
                      entry.remove();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.question_answer, size: 40,),
                        Text('File',style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width/5,
                  height: MediaQuery.of(context).size.width/5,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/upload_poll');
                      entry.remove();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.question_answer, size: 40,),
                        Text('Poll',style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width/5,
                  height: MediaQuery.of(context).size.width/5,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/upload_confession');
                      entry.remove();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.question_answer, size: 40,),
                        Text('Confession',style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width/5,
                  height: MediaQuery.of(context).size.width/5,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/upload_social');
                      entry.remove();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.question_answer, size: 40,),
                        Text('Social',style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
    return entry;
  }
}
