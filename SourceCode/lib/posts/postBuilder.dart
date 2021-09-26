import 'package:academics/chat/chatUtils.dart';
import 'package:academics/chat/model.dart';
import 'package:academics/chat/viewModel.dart';
import 'package:academics/cloud/firebaseUtils.dart';
import 'package:academics/folders/userFolders.dart';
import 'package:academics/posts/model.dart';
import 'package:academics/posts/viewmodel.dart';
import 'package:academics/reports/reportUtils.dart';
import 'package:academics/user/model.dart';
import 'package:academics/user/userUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../errors.dart';
import '../reports/report.dart';
import '../routes.dart';
import '../utils.dart';
import 'customWidgets.dart';

class PostBuilder {
  final Post post;
  final BuildContext context;

  SinglePostViewModel viewModel;
  TypeDataBuilder typeData;

  PostBuilder({@required this.post, @required this.context}) {
    viewModel = SinglePostViewModel(post);
    if (post != null) typeData = TypeDataBuilder.builder(post, viewModel);
  }

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
                for (var widget in typeData.buildFullPost(context, post.id))
                  Container(
                    color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: widget,
                  ),
                _createBottomBar(),
                for (var widget in typeData.buildExtra(context, post.id))
                  Container(
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: widget),
              ]),
            ),
          ),
          if (typeData.hasComments())
            typeData.buildAction(context, post.id, controller),
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
                typeData.buildHint(context),
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
              Text(
                (post.upVotes - post.downVotes).toString(),
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Icon(
                Icons.arrow_drop_up,
                color: Theme.of(context).accentColor,
              ),
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
                Navigator.of(context)
                    .pushNamed(Routes.userProfile, arguments: post.userid);
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
                            Routes.home, (r) => false,
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
    } else if (choice == PostActions.Share.toString()) {
      _sharePost();
    } else if (choice == PostActions.Move.toString()) {
      _movePost();
    } else if (choice == PostActions.Report.toString()) {
      sendReport(Report(
        post: {
          'post': post.id,
        },
        reason: await getReportReason([
          ReportReason.postInappropriate,
          ReportReason.postSpam,
          ReportReason.postWrongFolder
        ], context),
      ));
    }
  }

  void _sharePost() async {
    try {
      List<Chat> chats = await viewModel.currentUserChats;
      List<String> names = await Future.wait(
          List<Future<String>>.from(chats.map((e) => chatName(e))));

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
                          Icon((chats[index].name != null)
                              ? Icons.group
                              : Icons.person),
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
      ChatViewModel(chatId).sendChatMessage(post.id, 1);
    } catch (e) {
      print('sharePost $e');
    }
  }

  void _movePost() async {
    final path = await Navigator.of(context)
        .pushNamed(Routes.chooseFolder, arguments: post.folder);
    viewModel.movePost(path);
  }

  void deletePost() async {
    await viewModel.deletePost();
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (r) => false);
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

abstract class TypeDataBuilder {
  final SinglePostViewModel viewModel;

  static TypeDataBuilder builder(Post post, SinglePostViewModel viewModel) {
    switch (post.type) {
      case PostType.Question:
        return QuestionTypeBuilder(post.typeData, viewModel);
      case PostType.File:
        return FileTypeBuilder(post.typeData, viewModel);
      case PostType.Request:
        return RequestTypeBuilder(post.typeData, viewModel);
      case PostType.Poll:
        return PollTypeBuilder(post.typeData, viewModel);
      case PostType.Confession:
        return ConfessionTypeBuilder(post.typeData, viewModel);
      case PostType.Social:
        return SocialTypeBuilder(post.typeData, viewModel);
      default:
        print('null');
        return null;
    }
  }

  TypeDataBuilder(this.viewModel);

  List<Widget> buildFullPost(BuildContext context, String postId);

  List<Widget> buildExtra(BuildContext context, String postId);

  Widget buildHint(BuildContext context);

  Widget buildAction(
      BuildContext context, String postId, ScrollController controller) {
    return Container();
  }

  bool hasComments();
}

class QuestionTypeBuilder extends TypeDataBuilder {
  final QuestionDataWidget dataType;

  QuestionTypeBuilder(this.dataType, viewModel) : super(viewModel);

  @override
  List<Widget> buildFullPost(BuildContext context, String postId) {
    return [
      //comments
      TextWidget(dataType.question),
      if (this.dataType.imageId != null)
        ImageWidget(dataType.imageId, viewModel),
    ];
  }

  @override
  List<Widget> buildExtra(BuildContext context, String postId) {
    return [
      VoteWidget(viewModel),
      FollowWidget(
          'Notify me when there is an answer', viewModel, dataType.followers),
      Divider(height: 20),
      CommentWidget(
        viewModel,
        answer: true,
        accepted: dataType.acceptedAnswer,
      ),
    ];
  }

  @override
  Widget buildHint(BuildContext context) {
    return ImageHintWidget(
        description: dataType.question, imageId: dataType.imageId);
  }

  @override
  Widget buildAction(
      BuildContext context, String postId, ScrollController controller) {
    return UploadComment(
        postId: postId, hint: 'Give your answer', scrollController: controller);
  }

  @override
  bool hasComments() {
    return true;
  }
}

class FileTypeBuilder extends TypeDataBuilder {
  final FileDataWidget dataType;

  FileTypeBuilder(this.dataType, viewModel) : super(viewModel);

  @override
  List<Widget> buildFullPost(BuildContext context, String postId) {
    return [
      FileDownloadWidget(dataType.fileId, dataType.type, viewModel),
    ];
  }

  @override
  List<Widget> buildExtra(BuildContext context, String postId) {
    return [
      VoteWidget(viewModel),
    ];
  }

  @override
  Widget buildHint(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.picture_as_pdf,
          color: Theme.of(context).hintColor,
          size: 20,
        )
      ],
    );
  }

  @override
  bool hasComments() {
    return false;
  }
}

class RequestTypeBuilder extends TypeDataBuilder {
  final RequestDataWidget dataType;

  RequestTypeBuilder(this.dataType, viewModel) : super(viewModel);

  @override
  List<Widget> buildFullPost(BuildContext context, String postId) {
    return [SendFilePostWidget(viewModel)];
  }

  @override
  List<Widget> buildExtra(BuildContext context, String postId) {
    return [
      FollowWidget(
          'Notify me when there is a file', viewModel, dataType.followers),
    ];
  }

  @override
  Widget buildHint(BuildContext context) {
    return Column(
      children: [
        TextWidget('Add file'),
      ],
    );
  }

  @override
  bool hasComments() {
    return false;
  }
}

class PollTypeBuilder extends TypeDataBuilder {
  final PollDataWidget dataType;

  PollTypeBuilder(this.dataType, viewModel) : super(viewModel);

  @override
  List<Widget> buildFullPost(BuildContext context, String postId) {
    return [
      PollWidget(
        poll: dataType,
        postId: postId,
      ),
    ];
  }

  @override
  List<Widget> buildExtra(BuildContext context, String postId) {
    return [
      VoteWidget(viewModel),
    ];
  }

  @override
  Widget buildHint(BuildContext context) {
    return Text('${dataType.polls.length} Options');
  }

  @override
  bool hasComments() {
    return false;
  }
}

class ConfessionTypeBuilder extends TypeDataBuilder {
  final ConfessionDataWidget dataType;

  ConfessionTypeBuilder(this.dataType, viewModel) : super(viewModel);

  @override
  List<Widget> buildFullPost(BuildContext context, String postId) {
    return [
      TextWidget(dataType.confession),
    ];
  }

  @override
  List<Widget> buildExtra(BuildContext context, String postId) {
    return [
      VoteWidget(viewModel),
      CommentWidget(
        viewModel,
        answer: false,
      ),
    ];
  }

  @override
  Widget buildHint(BuildContext context) {
    return Column(
      children: [
        Text(
          dataType.confession,
          style: Theme.of(context).textTheme.bodyText2,
          maxLines: 2,
        ),
      ],
    );
  }

  @override
  Widget buildAction(
      BuildContext context, String postId, ScrollController controller) {
    return UploadComment(
        postId: postId, hint: 'Comment', scrollController: controller);
  }

  @override
  bool hasComments() {
    return true;
  }
}

class SocialTypeBuilder extends TypeDataBuilder {
  final SocialDataWidget dataType;

  SocialTypeBuilder(this.dataType, viewModel) : super(viewModel);

  @override
  List<Widget> buildFullPost(BuildContext context, String postId) {
    return [
      TextWidget(dataType.text),
      if (dataType.imageId != null) ImageWidget(dataType.imageId, viewModel),
    ];
  }

  @override
  List<Widget> buildExtra(BuildContext context, String postId) {
    return [
      VoteWidget(viewModel),
      CommentWidget(
        viewModel,
        answer: false,
      ),
    ];
  }

  @override
  Widget buildHint(BuildContext context) {
    return ImageHintWidget(
        description: dataType.text, imageId: dataType.imageId);
  }

  @override
  Widget buildAction(
      BuildContext context, String postId, ScrollController controller) {
    return UploadComment(
        postId: postId, hint: 'Comment', scrollController: controller);
  }

  @override
  bool hasComments() {
    return true;
  }
}

class PostListBuilder {
  Future<List<Post>> posts;
  BuildContext context;

  PostListBuilder({this.posts, this.context});

  Widget buildPostPage({Function loadMore}) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: FutureBuilder<List<Post>>(
        future: posts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Center(
                  child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No posts',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline2),
                  ),
                ],
              ));
            }
            return ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                for (Widget post in _createPostList(snapshot.data)) post,
                if (loadMore != null &&
                    snapshot.data.length == FetchConstant.fetchPostsLimit)
                  OutlinedButton(
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Text('Load more'),
                            Icon(Icons.add_circle_outline),
                          ],
                        )),
                    onPressed: () {
                      loadMore(snapshot.data.last.id);
                    },
                  )
              ],
            );
          } else if (snapshot.hasError) {
            print(snapshot
                .error); // .substring(11)); //removes the 'Exception: ' prefix
            return errorWidget(
                'An error occured while fetching posts', context);
          }
          return Container();
        },
      ),
    );
  }

  List<Widget> _createPostList(List<Post> posts) {
    return [
      for (Post post in posts)
        OutlinedButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamed(Routes.postPage, arguments: post.id);
          },
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).cardColor),
          ),
          child: PostBuilder(post: post, context: context).buildHintPost(),
        )
    ];
  }
}

enum PostActions {
  Save,
  Delete,
  Share,
  Move,
  Report,
}
