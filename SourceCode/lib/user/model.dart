import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AcademicsUser {
  final String id;
  final String department;
  final bool admin;
  final bool business;
  final List<String> liked;
  final List<String> disliked;
  final String email;
  final String displayName;
  final bool showEmail;
  final List<String> posts;
  final List<String> following;
  final List<String> folders;
  final List<bool> filters;
  final int points;

  AcademicsUser({
    this.id,
    @required this.admin,
    @required this.department,
    @required this.liked,
    @required this.disliked,
    @required this.email,
    @required this.displayName,
    @required this.showEmail,
    @required this.posts,
    @required this.filters,
    @required this.following,
    @required this.points,
    @required this.business,
    @required this.folders,
  });

  factory AcademicsUser.fromJson(Map<String, dynamic> json) {
    return AcademicsUser(
      id: json['id'],
      admin: json['admin'],
      department: json['department'],
      liked: json['liked'].cast<String>(),
      disliked: json['disliked'].cast<String>(),
      email: json['email'],
      displayName: json['display_name'],
      showEmail: json['show_email'],
      posts: json['posts'].cast<String>(),
      following: json['following'].cast<String>(),
      filters: json['filters'].cast<bool>(),
      points: json['points'],
      business: json['business'],
      folders: json['folders'].cast<String>(),
    );
  }

  factory AcademicsUser.decode(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data();
    data.addAll({'id': doc.id});
    return AcademicsUser.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'admin': admin,
      'department': department,
      'points': points,
      'liked': liked,
      'disliked': disliked,
      'email': email,
      'display_name': displayName,
      'show_email': showEmail,
      'posts': posts,
      'filters': filters,
      'following': following,
      'business': business,
      'folders': folders,
    };
  }
}


