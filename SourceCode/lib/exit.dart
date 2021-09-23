import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'errors.dart';

DateTime currentBackPressTime;
Future<bool> onWillPop(BuildContext context) {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime) > Duration(seconds: 2)) {
    currentBackPressTime = now;
    showError('Press back button again to exit app', context);
    return Future.value(false);
  }
  SystemNavigator.pop();
  return Future.value(true);
}