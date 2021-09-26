import 'package:academics/cloud/firebaseUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatViewModel with ChangeNotifier {
  final String chatId;

  ChatViewModel(this.chatId);

  Stream get messages {
    return FirebaseFirestore.instance
        .collection(Collections.chat)
        .doc(chatId)
        .collection(Collections.messages)
        .orderBy('timestamp', descending: true)
        .limit(FetchConstant.fetchChatLimit)
        .snapshots()
        .map((event) => List<Map<String, dynamic>>.from(event.docs.map((doc) {
              var data = doc.data();
              data.addAll({'id': doc.id});
              return data;
            })));
  }

  void sendChatMessage(String content, int type) {
    var time = DateTime.now().millisecondsSinceEpoch;
    uploadObject(
        Collections.chat,
        {
          'user': FirebaseAuth.instance.currentUser.uid,
          'timestamp': time,
          'content': content,
          'type': type
        },
        doc: chatId,
        subCollection: Collections.messages);
    FirebaseFirestore.instance
        .collection(Collections.chat)
        .doc(chatId)
        .set({'message': (type == 0) ? content : 'Post', 'time': time}, SetOptions(merge: true));
  }
}
