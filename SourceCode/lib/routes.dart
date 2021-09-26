import 'package:academics/posts/model.dart';

class Routes {
  static const String root = '/';
  static const String home = '/home';
  static const String auth = '/auth';
  static const String buildProfile = '/build_profile';

  static const String postPage = '/post_page';
  static const String messagePage = '/message_page';

  static const String reports = '/reports';
  static const String userFolder= '/user_folder';
  static const String userProfile = '/user_profile';
  static const String chat = '/chat';

  static const String postSearch = '/post_search';
  static const String chooseFolder = '/choose_folder';
  static const String choosePost = '/choose_post';

  static const String pdf = '/pdf';
  static const String switchAccount = '/switch';
  static const String emailSignIn = '/email_signin';

  static const String uploadQuestion = '/upload_question';
  static const String uploadFile = '/upload_file';
  static const String uploadRequest = '/upload_request';
  static const String uploadPoll = '/upload_poll';
  static const String uploadConfession = '/upload_confession';
  static const String uploadSocial = '/upload_social';

  static String uploadRoute(String type) {
    switch (type) {
      case PostType.Question:
        return uploadQuestion;
      case PostType.File:
        return uploadFile;
      case PostType.Request:
        return uploadRequest;
      case PostType.Poll:
        return uploadPoll;
      case PostType.Confession:
        return uploadConfession;
      case PostType.Social:
        return uploadSocial;
      default:
        return uploadQuestion;
    }
  }
}