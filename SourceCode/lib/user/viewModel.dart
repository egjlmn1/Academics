import 'package:academics/chat/model.dart';
import 'package:academics/cloud/firebaseUtils.dart';
import 'package:academics/posts/model.dart';
import 'package:academics/posts/postCloudUtils.dart';
import 'package:academics/user/model.dart';
import 'package:academics/user/userUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserViewModel with ChangeNotifier {
  final String userId;

  UserViewModel(this.userId);

  Future<AcademicsUser> get user {
    return fetchUser(userId);
  }

  Future<String> alreadyChatted() async {
    for (String chatId in (await FirebaseFirestore.instance
            .collection(Collections.users)
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection(Collections.chat)
            .get())
        .docs
        .map((e) => e.id)) {
      List<String> users = List.from(
          (await getDocSnapshot(Collections.chat, chatId)).get('users'));
      if (users.contains(userId)) {
        return chatId;
      }
    }
    return null;
  }

  Future<String> createChat(List<String> users, {String name}) async {
    String docId = await uploadObject(Collections.chat, {
      'message': 'chat started',
      'name': name,
      'time': DateTime.now().millisecondsSinceEpoch,
      'group': false,
      'users': users,
    });
    await Future.wait(users.map((user) => uploadObject(
        Collections.users,
        {
          'muted': false,
        },
        id: docId,
        doc: user,
        subCollection: Collections.chat)));
    return docId;
  }

  Future showEmail(bool show) {
    return updateObject(Collections.users, userId, 'show_email', show);
  }

  Future<List<Post>> getPosts() {
    return fetchPosts(user: userId);
  }

  Stream get userChatsStream {
    return FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection(Collections.chat)
        .snapshots();
  }

  Stream realChatsStream(List<String> ids) {
    return FirebaseFirestore.instance
        .collection(Collections.chat)
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots().map((event) =>  List<Chat>.from(event.docs.map((doc) => Chat.decode(doc))));
  }
}
