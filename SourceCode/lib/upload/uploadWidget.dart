
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

  static UploadWidget text() {return UploadWidget(widgetState: TextUploadWidget());}
  static UploadWidget image() {return UploadWidget(widgetState: ImageUploadWidget());}
  static UploadWidget file() {return UploadWidget(widgetState: FileUploadWidget());}
  static UploadWidget poll() {return UploadWidget(widgetState: PollUploadWidget());}

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

class TextUploadWidget extends _UploadWidgetState {
  var _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          hintText: "Your text (optional)"
      ),
      controller: _textController,
    );
  }

  @override
  Object data() {
    return _textController.text;
  }
}

class ImageUploadWidget extends _UploadWidgetState {
  final picker = ImagePicker();
  File _image;

  _imgFromGallery() async {
    PickedFile image = await picker.getImage(source: ImageSource.camera);
    // TODO add option for gallery (make the user pick between camera and gallery)
    setState(() {
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
              setState((){
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
  Widget build(BuildContext context) {
    return pickImage();
  }

  @override
  Object data() {
    return _image;
  }
}

class FileUploadWidget extends _UploadWidgetState {
  File _file;

  Future pickFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']
    );
    if(result != null) {
      File _file = File(result.files.single.path);
      _file.readAsBytesSync();
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextButton(
        onPressed: () {
          pickFile();
        },
        child: Text(
            'Upload'
        ),
      ),
    );
  }

  @override
  Object data() {
    return _file;
  }


}

class PollUploadWidget extends _UploadWidgetState {
  static const MAX_CHOICES = 6;
  List<TextEditingController> _polls = [TextEditingController(), TextEditingController()];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                    setState(() {
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
              setState(() {
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
    );
  }

  @override
  Object data() {
    return _polls;
  }
}
