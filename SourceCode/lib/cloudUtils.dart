

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';


Future<String> uploadFile(File _file) async {
  /**
   * function get a file, upload it to firebase cloud storage and returns the url of the file saved in cloud storage
   */
  FirebaseStorage  storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('postFiles/${basename(_file.path)}');
  await ref.putFile(_file);

  String returnURL = await ref.getDownloadURL();
  print('File Uploaded to cloud storage $returnURL');

  return returnURL;
}

Future<String> uploadObject(String path, Map<String, dynamic> object) async {
  /**
   * function get a json object and a path, upload it to firestore and returns the id of the object saved in firestore
   */
  CollectionReference posts = FirebaseFirestore.instance.collection(path);
  Future<DocumentReference> ref = posts.add(object);
  await ref.then((value) => print("object Uploaded to firestore $value"))
      .catchError((error) => print("Failed to upload to firestore: $error"));
  return ref.toString();
}

Future<String> deleteObject(String path, String id) async {
  /**
   * function get a id of the object and a path, delete it from firestore
   */
  CollectionReference posts = FirebaseFirestore.instance.collection(path);
  posts.doc(id).delete();
}