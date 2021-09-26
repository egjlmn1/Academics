import 'package:intl/intl.dart';

String timeToText(int time) {
  DateTime now = DateTime.now();
  DateTime then = DateTime.fromMillisecondsSinceEpoch(time);
  Duration timeAgo = now.difference(then);
  if (timeAgo.inDays > 3 || timeAgo.inSeconds < 0) {
    return DateFormat('dd/MM/yy').format(then);
  } else if (timeAgo.inHours > 23) {
    return '${timeAgo.inDays} days ago';
  } else if (timeAgo.inMinutes > 59) {
    return '${timeAgo.inHours} hours ago';
  } else if (timeAgo.inSeconds > 59) {
    return '${timeAgo.inMinutes} mins ago';
  } else {
    return '${timeAgo.inSeconds} secs ago';
  }
}