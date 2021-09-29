import 'package:academics/posts/postBuilder.dart';
import 'package:academics/upload/uploadType.dart';
import 'package:academics/upload/viewModel.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';
import '../errors.dart';
import '../posts/model.dart';
import '../routes.dart';

class UploadPage extends StatefulWidget {
  final UploadType _postType;
  final String folder;

  UploadPage(this._postType, {this.folder});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  //Folder _folder = Folder(path: 'root');
  //List<String> _tags = [];

  UploadPageViewModel viewModel;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    viewModel = UploadPageViewModel(widget._postType);
    if (widget.folder != null) {
      viewModel.folder = widget.folder;
    }
  }

  void postClicked() async {
    if (uploading) {
      return;
    }
    uploading = true;
    var valid = isValid();
    if (valid) {
      showError('Uploading post...', context);
      String id = await viewModel.postClicked();
      if (id != null) {
        showError('Post uploaded!', context);
        Navigator.of(context).pop(id);
      } else {
        showError('Failed to upload post', context);
      }
    } else {
      showError(widget._postType.error(), context);
    }
    uploading = false;
  }

  void chooseFolder() async {
    final result = await Navigator.of(context).pushNamed(Routes.chooseFolder, arguments: viewModel.folder);
    setState(() {
      viewModel.folder = (result == null) ? viewModel.folder : result;
    });
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
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: TextButton(
                            onPressed: () {
                              chooseFolder();
                            },
                            child: Container(
                              child: Text(viewModel.folder.split('/').last),
                            ),
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
                        viewModel.tags.add(tag);
                      },
                      onDelete: (tag) {
                        viewModel.tags.remove(tag);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int index = 0; index < PostType.types.length; index++)
            Flexible(
              child: TextButton(
                child: Row(
                  children: [
                    Icon(iconByType(PostType.types[index]), size: 50,),
                    SizedBox(width: 10,),
                    Text(PostType.types[index], style: TextStyle(fontSize: 30),),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.uploadRoute(PostType.types[index]));
                },
              ),
            )
        ],
      ),
    );
  }
}
