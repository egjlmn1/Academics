import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Folder {
  String _name;
  String path;
  FolderType type;

  Folder({this.path, this.type=FolderType.folder}) {
    var splitted = this.path.split('/');
    _name = splitted[splitted.length - 1];
  }

  IconData icon() {
    if (type == FolderType.folder) {
      return Icons.folder;
    } else {
      return Icons.school;
    }
  }

  String name() {
    return _name;
  }

  Widget build() {
    return Row(
        children: [
          Icon(icon()),
          Text(name()),
        ],
      );
  }
}

enum FolderType {
  folder,
  university,
}

