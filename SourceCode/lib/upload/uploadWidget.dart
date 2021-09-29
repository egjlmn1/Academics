import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadWidget extends StatefulWidget {
  final _UploadWidgetState widgetState;

  UploadWidget({this.widgetState});

  Object data() {
    return widgetState.data();
  }

  static UploadWidget title(String hint, {bool required = false}) {
    return UploadWidget(widgetState: TitleUploadWidget(hint, required));
  }

  static UploadWidget text(String hint, {bool required = false}) {
    return UploadWidget(widgetState: TextUploadWidget(hint, required));
  }

  static UploadWidget image({bool required = false}) {
    return UploadWidget(widgetState: ImageUploadWidget(required));
  }

  static UploadWidget file({bool required = false}) {
    return UploadWidget(widgetState: FileUploadWidget(required));
  }

  static UploadWidget poll({bool required = false}) {
    return UploadWidget(widgetState: PollUploadWidget(required));
  }

  static UploadWidget choices(List<String> choices,
      {bool required = false, bool other = false}) {
    return UploadWidget(
        widgetState: ChoicesUploadWidget(choices, required, other));
  }

  @override
  _UploadWidgetState createState() => widgetState;
}

abstract class _UploadWidgetState extends State<UploadWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Object data();
}

class TitleUploadWidget extends _UploadWidgetState {
  final String hint;
  final bool required;

  TitleUploadWidget(this.hint, this.required);

  var _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 20),
        child: TextField(
          maxLength: 256,
          decoration: InputDecoration(hintText: hint),
          style: Theme.of(context).textTheme.subtitle1,
          controller: _textController,
        ));
  }

  @override
  Object data() {
    if (required && _textController.text.trim().isEmpty) {
      return null;
    }
    return _textController.text.trim();
  }
}

class TextUploadWidget extends _UploadWidgetState {
  final String hint;
  final bool required;

  TextUploadWidget(this.hint, this.required);

  var _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: 1024,
      decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          hintStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 15,
          ),
          hintText: hint),
      style: Theme.of(context).textTheme.bodyText2,
      controller: _textController,
    );
  }

  @override
  Object data() {
    if (required && _textController.text.trim().isEmpty) {
      return null;
    }
    return _textController.text.trim();
  }
}

class ImageUploadWidget extends _UploadWidgetState {
  final picker = ImagePicker();
  File _image;
  final bool required;

  ImageUploadWidget(this.required);

  Widget _buildPickDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Image'),
      content: const Text('Choose where to upload the image from'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            pickImage(ImageSource.camera);
            Navigator.of(context).pop();
          },
          child: const Text('Camera'),
        ),
        TextButton(
          onPressed: () {
            pickImage(ImageSource.gallery);
            Navigator.of(context).pop();
          },
          child: const Text('Gallery'),
        ),
      ],
    );
  }

  pickImage(ImageSource source) async {
    XFile image = await picker.pickImage(source: source);
    setState(() {
      if (image != null) {
        _image = File(image.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_image != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
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
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildPickDialog(context),
          );
        },
        child: Container(
          child: Text('Image (optional)'),
        ),
      );
    }
  }

  @override
  Object data() {
    if (required && _image == null) {
      return null;
    } //cant return null in both cases fix this and continue to file and poll (doesnt matter image is never required)
    return _image; //Bad because if not required and image is null its good
  }
}

class FileUploadWidget extends _UploadWidgetState {
  File _file;
  final bool required;

  FileUploadWidget(this.required);

  Future pickFile() async {
    FilePickerResult result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      _file = File(result.files.single.path);
      setState(() {});
      //_file.readAsBytesSync();
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_file != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                _file = null;
              });
            },
            child: Container(
              child: Text('Remove File'),
            ),
          ),
          Flexible(
            child: Text(
              _file.path.split('/').last,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      );
    } else {
      return TextButton(
        onPressed: () {
          pickFile();
        },
        child: Container(
          child: Text('Upload File'),
        ),
      );
    }
  }

  @override
  Object data() {
    return _file;
  }
}

class PollUploadWidget extends _UploadWidgetState {
  final bool required;

  PollUploadWidget(this.required);

  static const MAX_CHOICES = 6;
  List<TextEditingController> _polls = [
    TextEditingController(),
    TextEditingController()
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: List<Widget>.generate(_polls.length, (index) {
            return index >= 2
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _polls[index],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _polls.removeAt(index);
                          });
                        },
                        child: Icon(Icons.close),
                      )
                    ],
                  )
                : TextField(
                    controller: _polls[index],
                  );
          }),
        ),
        TextButton(
          onPressed: () {
            if (_polls.length < MAX_CHOICES) {
              setState(() {
                _polls.add(TextEditingController());
              });
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Add Choice'), Icon(Icons.add)],
          ),
        )
      ],
    );
  }

  @override
  Object data() {
    return List<String>.from(
        _polls.map((e) => e.text.trim()));
  }
}

class ChoicesUploadWidget extends _UploadWidgetState {
  final bool other;
  final bool required;
  final List<String> choices;

  int chosen;

  ChoicesUploadWidget(
    this.choices,
    this.required,
    this.other,
  );

  TextEditingController _otherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,

            children: [
              for (int i=0;i<choices.length;i++)
                OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: (chosen != null && i==chosen) ?
                    MaterialStateProperty.all(Theme.of(context).primaryColor) : MaterialStateProperty.all(Theme.of(context).cardColor),
                  ),
                  onPressed: () {
                    setState(() {
                      chosen = i;
                    });
                  },
                  child: Text(choices[i], style: Theme.of(context).textTheme.subtitle2,),
                ),
            ],
          ),
        ),
        if (other)
          Container(
            width: 150,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'other type',
                filled: true,
                fillColor: (chosen != null && choices.length==chosen) ?
                Theme.of(context).primaryColor : Theme.of(context).cardColor,
              ),
              controller: _otherController,
              maxLength: 64,
              onTap: () {
                print('tap');
                setState(() {
                  chosen = choices.length;
                });
              },
            ),
          ),
      ],
    );
  }

  @override
  Object data() {
    if (chosen == null) {
      return null;
    } else if(chosen == choices.length) {
      return _otherController.text.trim().isNotEmpty ? _otherController.text.trim() : null;
    }
    return choices[chosen];
  }
}
