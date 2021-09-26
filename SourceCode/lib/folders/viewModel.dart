import 'package:academics/cloud/firebaseUtils.dart';
import 'package:academics/posts/model.dart';
import 'package:academics/posts/postCloudUtils.dart';
import 'package:academics/user/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'folders.dart';
import 'foldersUtil.dart';

class UserFoldersViewModel with ChangeNotifier {
  Future<List<Map<String, dynamic>>> get folders async {
    return List.from((await fetchInBatches(Collections.userFolders,
            List.from((await getUserFolders()).map((e) => e.path))))
        .map((DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data();
      data.addAll({'id': doc.id});
      return data;
    }));
  }

  Future uploadPost(String folderId, String postId) {
    return uploadObject(
        Collections.userFolders,
        {
          'id': postId,
        },
        doc: folderId,
        subCollection: Collections.posts);
  }

  Future createFolder(String path) async {
    String id = await uploadObject(Collections.userFolders, {
      'path': path,
      'owner': FirebaseAuth.instance.currentUser.uid,
    });
    return addToObject(Collections.users,
        FirebaseAuth.instance.currentUser.uid, Collections.folders, id);
  }
}

class SingleUserFolderViewModel with ChangeNotifier {

  final String folderId;

  SingleUserFolderViewModel(this.folderId);

  Future shareToUser(String user) {
    return addToObject(
        Collections.users, user, Collections.folders, folderId);
  }

  Future<List<Post>> get posts {
    return fetchPosts(
        folder: Folder(path: folderId, type: FolderType.user));
  }

}

class FoldersPageViewModel with ChangeNotifier {


  FoldersPageViewModel({String path:'root'}) {_path=path;}
  String _path = 'root';

  set path(String value) {
    _path = value;
    notifyListeners();
  }

  String get path {
    return _path;
  }

  Future<List<Post>> getPosts() {
    return fetchPosts(
        folder:
        Folder(path: _path, type: FolderType.folder));
  }

  Future<List<Folder>> getFolders(String search) {
    return fetchSubFolders(_path,
        prefix: search);
  }

  Future<void> saveFolder(AcademicsUser user, Folder folder) async {
    bool isFollowing = user.following.contains(folder.path);

    if (!isFollowing) {
      isFollowing = true;
      await addToObject(Collections.users, user.id, 'following', folder.path);
    } else {
      isFollowing = false;
      await removeFromObject(
          Collections.users, user.id, 'following', folder.path);
    }

    notifyListeners();
  }
}

