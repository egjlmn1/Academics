import 'package:academics/chat/chatPage.dart';
import 'package:academics/folders/userFolders.dart';
import 'package:academics/posts/postUtils.dart';
import 'package:academics/posts/schemes.dart';
import 'package:academics/reports/reportUtils.dart';
import 'package:academics/user/user.dart';
import 'package:academics/user/userUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../cloudUtils.dart';
import '../errors.dart';
import '../reports/report.dart';
import 'customWidgets.dart';

class PostCreator {
  Post post;
  BuildContext context;

  PostCreator({this.post, this.context});

  Widget buildFullPost() {
    if (post == null) {
      return errorWidget('Post does not exist', context);
    }
    ScrollController controller = ScrollController();
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              child:
                  ListView(controller: controller, shrinkWrap: true, children: [
                _createTopBar(),
                for (var widget
                    in post.typeData.buildFullPost(context, post.id))
                  widget,
                _createBottomBar(),
                for (var widget in post.typeData.buildExtra(context, post.id))
                  widget,
              ]),
            ),
          ),
          if (post.typeData.hasComments())
            post.typeData.buildAction(context, post.id, controller),
        ],
      ),
    );
  }

  Widget buildHintPost() {
    if (post == null) {
      return errorWidget('Post does not exist', context);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 70, child: _buildPostInfo()),
        VerticalDivider(
          color: Theme.of(context).hintColor,
          width: 1,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                post.typeData.buildHint(context),
                TagsWidget(tags: post.tags),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: _buildPostTimeUser(),
                    ),
                    if (post.folder != 'root')
                      Flexible(
                        flex: 1,
                        child: _buildPostFolder(),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
        _createPostMenu(),
      ],
    );
  }

  Widget _buildPostTimeUser({bool hint = true}) {
    return Text(
      '${timeToText(post.uploadTime)}, ${post.username}',
      style: TextStyle(
        fontSize: 8.0,
        color: Theme.of(context).accentColor,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: hint ? 1 : 10,
    );
  }

  Widget _buildPostFolder({bool hint = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.folder,
          size: 10,
          color: Theme.of(context).hintColor,
        ),
        Flexible(
          child: Text(
            post.folder.split('/').last,
            style: TextStyle(
              fontSize: 8.0,
              color: Theme.of(context).accentColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: hint ? 1 : 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPostInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.type,
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 13,
          ),
        ),
        if ((post.type != PostType.Poll) && (post.type != PostType.Request))
          Row(
            children: [
              Text((post.upVotes - post.downVotes).toString(), style: Theme.of(context).textTheme.bodyText2,),
              Icon(Icons.arrow_drop_up, color: Theme.of(context).accentColor,),
            ],
          ),
      ],
    );
  }

  Widget _createTopBar() {
    return Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.symmetric(horizontal: 1, vertical: 10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: _buildPostInfo()),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        post.title,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      TagsWidget(tags: post.tags),
                    ],
                  ),
                ),
              ),
              _createPostMenu(),
            ],
          ),
        ]));
  }

  Widget _createBottomBar() {
    return Container(
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: TextButton(
              child: _buildPostTimeUser(hint: false),
              onPressed: () {
                Navigator.of(context).pushNamed('/user_profile', arguments: post.userid);
              },
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (post.folder != 'root')
                  Flexible(
                    flex: 1,
                    child: TextButton(
                      child: _buildPostFolder(hint: false),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/home', (r) => false,
                            arguments: {'folder': post.folder});
                      },
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _createPostMenu() {
    return FutureBuilder(
        future: fetchUser(FirebaseAuth.instance.currentUser.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return Container();
          }
          AcademicsUser user = snapshot.data;
          return PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).textTheme.bodyText2.color,
            ),
            onSelected: _postActionSelect,
            itemBuilder: (BuildContext context) {
              return _reduceByUser(PostActions.values.toList(), user.admin)
                  .map((PostActions choice) {
                return PopupMenuItem<String>(
                  child: Text(
                    choice.toString().split('.')[1],
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  value: choice.toString(),
                );
              }).toList();
            },
          );
        });
  }

  List<PostActions> _reduceByUser(List<PostActions> actions, bool isAdmin) {
    if (!isAdmin) {
      actions.remove(PostActions.Move);
    }
    if (post.userid != FirebaseAuth.instance.currentUser.uid) {
      if (!isAdmin) {
        actions.remove(PostActions.Delete);
      }
    } else {
      //actions.remove(PostActions.Report);
    }
    return actions;
  }

  void _postActionSelect(String choice) async {
    if (choice == PostActions.Save.toString()) {
      _savePost();
    } else if (choice == PostActions.Delete.toString()) {
      deletePost();
    }else if (choice == PostActions.Share.toString()) {
      _sharePost();
    } else if (choice == PostActions.Move.toString()) {
      _movePost();
    } else if (choice == PostActions.Report.toString()) {
      sendReport(Report(
        post: {
            'post': post.id,
          },
          reason: await getReportReason([ReportReason.postInappropriate, ReportReason.postSpam, ReportReason.postWrongFolder], context),
      ));
    }
  }

  void _sharePost() async {
    try {
      //AcademicsUser user = await fetchUser(FirebaseAuth.instance.currentUser.uid);
      List<String> chatsIds = List.from((await getDocs(Collections.users, doc: FirebaseAuth.instance.currentUser.uid,subCollection: Collections.chat)).map((e) => e.id));
      List<DocumentSnapshot> chats = await fetchInBatches(Collections.chat, chatsIds);
      List<String> names = await Future.wait(List<Future<String>>.from(chats.map((e) => chatName(e))));
      String chatId = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Search chat'),
              content: Container(
                height: double.infinity,
                width: 300,
                child: ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    return TextButton(
                      child: Row(
                        children: [
                          Icon((chats[index].get('name') != null) ? Icons.group: Icons.person),
                          Text(names[index]),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(chats[index].id);
                      },
                    );
                  },
                ),
              ),
            );
          });
      sendChatMessage(post.id, 1, chatId);
    } catch(e) {
      print('sharePost $e');
    }
  }

  void _movePost() async {
    final path = await Navigator.of(context).pushNamed('/choose_folder', arguments: post.folder);
    updateObject('posts', post.id, 'folder', path);
    _deleteFromFolder();
    await addToFolder(post.id, path);
  }

  void deletePost() async {
    if (post.typeData.file() != null) {
      deleteFile(post.typeData.file());
    }

    await Future.wait([
      _deleteFromFolder(),
      removeFromObject(Collections.users, post.userid, 'posts', post.id),
      _deleteComments(),
      deleteObject('posts', post.id)
    ]);
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
  }

  Future<void> _deleteComments() async {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .collection('comments')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  Future<void> _deleteFromFolder() async {
    try {
      String folderId = await findDocId('folders', 'path', post.folder);
      deleteObject(
          'folders',
          (await findDocId('folders', 'id', post.id,
              doc: folderId, subCollection: 'posts')),
          doc: folderId,
          subCollection: 'posts');
    } catch (e) {
      print('error in deleting from folder: $e');
    }
  }

  void _savePost() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 16,
          child: UploadToFolders(postId: post.id),
        );
      },
    );
  }
}

enum PostActions {
  Save,
  Delete,
  Share,
  Move,
  Report,
}
