import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chat {
  // posts received from server and shown on screen
  final String id;
  final bool group;
  final String lastMessage;
  final String name;
  final int time;
  final List<String> users;

  Chat({
    this.id,
    @required this.group,
    @required this.lastMessage,
    @required this.name,
    @required this.time,
    @required this.users,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      group: json['group'],
      lastMessage: json['message'],
      name: json['name'],
      time: json['time'],
      users: json['users'].cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group': group,
      'message': lastMessage,
      'name': name,
      'time': time,
      'users': users,
    };
  }

  factory Chat.decode(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data();
    data.addAll({'id': doc.id});
    return Chat.fromJson(data);
  }
}
