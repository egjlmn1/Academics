import 'package:academics/user/userUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'model.dart';

Future<String> chatName(Chat chat) async {
  if (chat.name != null) {
    return chat.name;
  }
  List<String> users = List<String>.from(chat.users);
  users.remove(FirebaseAuth.instance.currentUser.uid);
  return (await fetchUser(users[0])).displayName;
}