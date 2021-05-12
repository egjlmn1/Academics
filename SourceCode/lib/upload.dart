
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'schemes.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
    var valid = isValid();
    print(valid);
    if (valid) {
      ShowPost post = ShowPost(
        title: _titleController.text,
        folder: _folder,
        username: 'TODO(get current username)',
        university: _isUniversity ? 'TODO(get university)' : null,
        type: _postType.type,
        typeData: _postType.createDataObject(),
        tags: _tags,
      );
      sendPost(post);
    } else {
      showErrors();
    }
  }

  void chooseFolder() async {
    final result = await Navigator.pushNamed(context, '/chooseFolder');
    setState(() {
      _folder = result == null ? _folder : result;
    });
  }

  void sendPost(ShowPost post) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    posts.add(post.toJson()).then((value) => print("Post Uploaded $value"))
        .catchError((error) => print("Failed to add user: $error"));
    print('post uploaded?');
  }

  void showErrors() {
    // show errors
    _postType.showErrors();
  }

  bool isValid() {
    return
      !_titleController.text.isEmpty
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
                      TextButton(
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
                  _postType.createUploadPage(setState),
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
                    color: Colors.black,
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
                    color: Colors.black,
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

abstract class UploadType {
  final String type;

  UploadType(this.type);

  Widget createUploadPage(Function setState);
  bool isValid();
  void showErrors();
  PostDataWidget createDataObject();
}

class QuestionUploadType extends UploadType {

  final picker = ImagePicker();
  Function _setState;
  File _image;
  var _textController = TextEditingController();


  QuestionUploadType() : super(PostType.Question);

  _imgFromGallery() async {
    PickedFile image = await picker.getImage(source: ImageSource.camera);
    // TODO add option for gallery (make the user pick between camera and gallery)
    _setState(() {
      if (image != null) {
        _image = File(image.path);
      }
    });
  }

  Widget pickImage() {
    if (_image != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              _setState((){
                _image = null;
              });
            },
            child: Container(
              child: Text('Remove Image'),
            ),
          ),
          Image.file(_image),
        ],
      );
    } else {
      return TextButton(
        onPressed: () {
          _imgFromGallery();
        },
        child: Container(
          child: Text('Image (optional)'),
        ),
      );
    }
  }

  @override
  Widget createUploadPage(Function setState) {
    _setState = setState;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "Your text (optional)"
            ),
            controller: _textController,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: pickImage(),
          ),
        ],
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
      data: _textController.text,
    );
  }

  @override
  void showErrors() {
    // always valid
  }
}

class FileUploadType extends UploadType {



  FileUploadType() : super(PostType.File);

  Future pickFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf']
    );
    if(result != null) {
      File file = File(result.files.single.path);
      file.readAsBytesSync();
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget createUploadPage(Function setState) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "File description (optional)"
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: TextButton(
              onPressed: () {
                pickFile();
              },
              child: Text(
                'Upload'
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

  static const MAX_CHOICES = 6;
  var _textController = TextEditingController();
  List<TextEditingController> _polls = [TextEditingController(), TextEditingController()];
  Function _setState;

  PollUploadType() : super(PostType.Poll);

  Map<String,int> createPolls() {
    return {'test':5};
  }

  @override
  Widget createUploadPage(Function setState) {
    _setState = setState;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "Your text (optional)"
            ),
            controller: _textController,
          ),
          Column(
            children: List<Widget>.generate(_polls.length, (index) {
              return index >= 2 ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _polls[index],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _setState(() {
                        _polls.removeAt(index);
                      });
                    },
                    child: Icon(Icons.close),
                  )
                ],
              ) :
              TextField(
                controller: _polls[index],
              );
            }),
          ),
          TextButton(
            onPressed: () {
              if (_polls.length < MAX_CHOICES) {
                _setState(() {
                  _polls.add(TextEditingController());
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'Add Choice'
                ),
                Icon(Icons.add)
              ],
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
    return PollDataWidget(
      question: _textController.text,
      polls: createPolls(),
    );
  }

  @override
  void showErrors() {
    // TODO: implement showErrors
  }
}

class ConfessionUploadType extends UploadType {
  ConfessionUploadType() : super(PostType.Confession);

  @override
  Widget createUploadPage(Function setState) {
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
  Widget createUploadPage(Function setState) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.question_answer, size: 40,color: Colors.black,),
                        Text(options[index],style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
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
