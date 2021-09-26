import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Report {
  final String reason;
  final Map<String, String> post;
  final int amount;
  String id;

  Report({this.id, @required this.reason, @required this.post, this.amount = 0});

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reason: json['reason'],
      post: Map<String, String>.from(json['post']),
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'post': post,
      'amount': amount,
    };
  }
}

class ReportReason {
  static const String postWrongFolder = 'Post in the wrong folder';
  static const String postInappropriate = 'Post is Inappropriate';
  static const String postSpam = 'Post is spam';
  static const String userInappropriate = 'User is Inappropriate';
  static const String commentInappropriate = 'Comment is Inappropriate';
  static const String commentSpam = 'Comment is spam';
}

Future<String> getReportReason(
    List<String> reasons, BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Choose reason'),
            content: Column(
              children: [
                for (String reason in reasons)
                  TextButton(
                    child: Text(reason),
                    onPressed: () {
                      Navigator.of(context).pop(reason);
                    },
                  )
              ],
            ));
      });
}
