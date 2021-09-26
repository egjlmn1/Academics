import 'package:academics/user/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cloud/firebaseUtils.dart';

Future<AcademicsUser> fetchUser(String id) async {
  AcademicsUser user = AcademicsUser.decode(await getDocSnapshot(Collections.users, id));
  return user;
}

Future<List<AcademicsUser>> fetchUsers({String folder, List<String> ids}) async {
  if (folder != null) {
    var docs = (await FirebaseFirestore.instance
        .collection(Collections.users)
        .where('following', arrayContains: folder)
        .where('business', isEqualTo: false)
        .orderBy('points', descending: true)
        .get())
        .docs;
    return List.from(docs.map((e) => AcademicsUser.decode(e)));
  } else {
    List<DocumentSnapshot> docs = await fetchInBatches(Collections.users, ids);
    return List.from(docs.map((doc) => AcademicsUser.decode(doc)));
  }

}

Future<List<AcademicsUser>> getKnownUsers() async {
  List<DocumentSnapshot> chatsIds = await getDocs(Collections.users,
      doc: FirebaseAuth.instance.currentUser.uid,
      subCollection: Collections.chat);
  List<DocumentSnapshot> chats = await fetchInBatches(
      Collections.chat, List.from(chatsIds.map((e) => e.id)));
  Set<String> usersId =
  Set.from(chats.map((e) => e.get('users')).expand((pair) => pair));
  usersId.remove(FirebaseAuth.instance.currentUser.uid);

  return fetchUsers(ids: List.from(usersId));
}