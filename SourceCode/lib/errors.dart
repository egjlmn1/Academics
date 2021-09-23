import 'package:flutter/material.dart';

Widget errorWidget(String text, BuildContext context) {
  return Center(
      child: Text(
    text,
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.headline2,
  ));
}

void showError(String text, BuildContext context) {
  ScaffoldMessenger.of(context)
      .clearSnackBars();
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));
}