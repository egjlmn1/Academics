import 'dart:convert';

import 'package:academics/folders/folders.dart';
import 'package:academics/posts/schemes.dart';
import 'package:http/http.dart' as http;

Future<http.Response> fetchResponse(String path) {
  return http.get(Uri.parse('http://3.126.130.122/' + path));
}


Future<List<Folder>> fetchHttpFolders(String folderSearch, {bool department = false, String folder}) async {
  String uri =  'search/folder/?pattern=' + folderSearch+'&departments=${department?'true':'false'}&main_folder=${folder!=null? folder:'root'}';
  http.Response response = await fetchResponse(uri);
  var decoded = jsonDecode(response.body);
  List<Map<String, dynamic>> foldersMaps = List.from(decoded);
  foldersMaps.removeWhere((f) => f['path']==folder);
  foldersMaps.sort((a,b)=>b['type'].compareTo(a['type']));
  List<Folder> folders = List.from(foldersMaps.map((e) => Folder(path: e['path'])));
  return folders;
}

Future<List<Post>> fetchHttpPosts(String search, int limit, {String lastId}) async {
  String uri = 'search/post?pattern=$search&limit=$limit${(lastId == null)?'':'&start_after_id=$lastId'}';
  http.Response response = await fetchResponse(uri);
  var decoded = jsonDecode(response.body);
  List<Map<String, dynamic>> postsMaps = List.from(decoded);
  List<Post> posts = List.from(postsMaps.map((json) => Post.fromJson(json)));
  return posts;
}