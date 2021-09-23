import '../cloudUtils.dart';

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
