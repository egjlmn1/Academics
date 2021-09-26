

import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FetchConstant {
  static const int fetchPostsLimit = 100;
  static const int fetchChatLimit = 100;

}

class Collections {
  static const String users = 'users';
  static const String chat = 'chats';
  static const String inbox = 'inbox';
  static const String folders = 'folders';
  static const String userFolders = 'userFolders';
  static const String reports = 'reports';
  static const String posts = 'posts';
  static const String messages = 'messages';
  static const String comments = 'comments';
}

Future<String> uploadFile(File _file, String path) async {
  /**
   * function get a file, upload it to firebase cloud storage and returns the path of the file saved in cloud storage
   */
  FirebaseStorage  storage = FirebaseStorage.instance;
  //String filePath = '${path}/${basename(_file.path)}';
  Reference ref = storage.ref().child(path);
  await ref.putFile(_file);

  //String returnURL = await ref.getDownloadURL();

  //print('File Uploaded to cloud storage $returnURL');

  return path;
}

Future<bool> deleteFile(String path) async {
  try {
    await FirebaseStorage.instance.ref(path).delete();
    return true;
  } catch(e) {
    return false;
  }
}


Future<String> uploadObject(String collection, Map<String, dynamic> object, {String id, String doc, String subCollection}) async {
  /**
   * function get a json object and a path, upload it to firestore and returns the id of the object saved in firestore
   */
  CollectionReference posts = _getCollection(collection, doc: doc, subCollection: subCollection);
  DocumentReference ref;
  if (id == null) {
    ref = await posts.add(object);
  } else {
    ref = posts.doc(id);
    ref.set(object);
  }
  return ref.id;
}

Future<void> updateObject(String collection, String id, String field, dynamic newObj, {String doc, String subCollection}) async {
  CollectionReference ref = _getCollection(collection, doc: doc, subCollection: subCollection);
  ref.doc(id).update({field: newObj});
}

Future<void> addToObject(String collection, String id, String field, dynamic addedObj, {String doc, String subCollection}) async {
  CollectionReference ref = _getCollection(collection, doc: doc, subCollection: subCollection);
  return await ref.doc(id).update({field: FieldValue.arrayUnion([addedObj])});
}

Future<void> removeFromObject(String collection, String id, String field, dynamic removedObj, {String doc, String subCollection}) async {
  CollectionReference ref = _getCollection(collection, doc: doc, subCollection: subCollection);
  return await ref.doc(id).update({field: FieldValue.arrayRemove([removedObj])});
}

Future<void> deleteObject(String collection, String id, {String doc, String subCollection}) async {
  /**
   * function get a id of the object and a path, delete it from firestore
   */
  CollectionReference posts = _getCollection(collection, doc: doc, subCollection: subCollection);
  await posts.doc(id).delete();
}

Future<String> findDocId(String collection, String field, dynamic value, {String doc, String subCollection}) async {
  return (await _getCollection(collection, doc: doc, subCollection: subCollection)
      .where(field, isEqualTo: value)
      .limit(1)
      .get())
  .docs[0]
  .id;
}

CollectionReference _getCollection(String collection, {String doc, String subCollection}) {
  CollectionReference c = FirebaseFirestore.instance
      .collection(collection);
  if (doc != null && subCollection != null) {
    c= c.doc(doc).collection(subCollection);
  }
  return c;
}

Future<DocumentSnapshot> getDocSnapshot(String collection, String id, {String doc, String subCollection}) async {
  return await _getCollection(collection, doc: doc, subCollection: subCollection).doc(id).get();
}

Future<List<DocumentSnapshot>> getDocs(String collection, {String doc, String subCollection}) async {
  return (await _getCollection(collection, doc: doc, subCollection: subCollection).get()).docs;
}

Future<List<DocumentSnapshot>> fetchInBatches(String collection, List<String> ids, {String doc, String subCollection}) async {
  List<DocumentSnapshot> docs = [];
  for (int i = 0; i < (ids.length / 10).ceil(); i++) {
    List<String> subIds = ids.sublist(i * 10, min((i + 1) * 10, ids.length));
    Query ref = _getCollection(collection, doc: doc, subCollection: subCollection)
        .where(FieldPath.documentId, whereIn: subIds);
    docs.addAll((await ref.get()).docs);
  }
  docs.sort((a,b)=>ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
  return docs;
}