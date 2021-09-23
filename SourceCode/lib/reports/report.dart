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
  static final String postWrongFolder = 'Post in the wrong folder';
  static final String postInappropriate = 'Post is Inappropriate';
  static final String postSpam = 'Post is spam';
  static final String userInappropriate = 'User is Inappropriate';
  static final String commentInappropriate = 'Comment is Inappropriate';
  static final String commentSpam = 'Comment is spam';
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
