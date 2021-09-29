import 'package:academics/errors.dart';
import 'package:academics/inbox/message.dart';
import 'package:academics/posts/postBuilder.dart';
import 'package:academics/posts/model.dart';
import 'package:academics/posts/postCloudUtils.dart';
import 'package:academics/posts/viewmodel.dart';
import 'package:academics/reports/report.dart';
import 'package:academics/reports/reportUtils.dart';
import 'package:academics/user/model.dart';
import 'package:academics/user/userUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../cloud/firebaseUtils.dart';
import '../routes.dart';
import '../utils.dart';

class PollWidget extends StatefulWidget {
  final PollDataWidget poll;
  final String postId;

  PollWidget({this.poll, this.postId});

  @override
  _PollWidgetState createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.poll.voted.keys
        .contains(FirebaseAuth.instance.currentUser.uid)) {
      return voteCasted(context);
    } else {
      return voterWidget(context);
    }
  }

  Widget voterWidget(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int index = 0; index < widget.poll.polls.length; index++)
          OutlinedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).cardColor),
            ),
            onPressed: () {
              setState(() {
                widget.poll.voted
                    .addAll({FirebaseAuth.instance.currentUser.uid: index});
                widget.poll.polls[List.from(widget.poll.polls.keys)[index]]++;
                updateObject(Collections.posts, widget.postId, 'typeData',
                    widget.poll.toJson());
              });
            },
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(0, 3, 10, 3),
              child: Text(
                widget.poll.polls.keys.toList()[index],
              ),
            ),
          ),
      ],
    );
  }

  Widget voteCasted(context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int index = 0; index < widget.poll.polls.length; index++)
            Container(
              margin: EdgeInsets.fromLTRB(0, 3, 10, 3),
              width: double.infinity,
              child: LinearPercentIndicator(
                animation: true,
                lineHeight: 38.0,
                animationDuration: 500,
                percent: evaluteAt(index),
                center: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.poll.polls.keys.toList()[index],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        myOwnChoice(widget.poll
                                .voted[FirebaseAuth.instance.currentUser.uid] ==
                            index)
                      ],
                    ),
                    Text(
                      ((evaluteAt(index) * 100).toInt()).toString() + "%",
                    )
                  ],
                ),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: Theme.of(context).primaryColor,
              ),
            ),
        ]);
  }

  Widget myOwnChoice(choice) {
    if (choice) {
      return Icon(
        Icons.check_circle_outline,
        color: Theme.of(context).accentColor,
        size: 17,
      );
    } else {
      return Container();
    }
  }

  double evaluteAt(int index) {
    if (widget.poll.polls.values.toList().reduce((a, b) => a + b) == 0) {
      return 0;
    }
    return widget.poll.polls.values.toList()[index] /
        widget.poll.polls.values.toList().reduce((a, b) => a + b);
  }
}

class ImageWidget extends StatelessWidget {
  final SinglePostViewModel viewModel;
  final String image;

  ImageWidget(this.image, this.viewModel);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: viewModel.getFileUrl(image),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.network(
              snapshot.data,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        });
  }
}

class TextWidget extends StatelessWidget {
  final String text;

  TextWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }
}

class VoteWidget extends StatelessWidget {
  final SinglePostViewModel viewModel;

  const VoteWidget(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        child: FutureBuilder<Widget>(
            future: _buildVotesState(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data;
              }
              return Container();
            }));
  }

  Future<Widget> _buildVotesState() async {
    bool like = false;
    bool dislike = false;
    AcademicsUser user;
    try {
      user = await fetchUser(FirebaseAuth.instance.currentUser.uid);
    } catch (e) {
      return Container();
    }
    List<String> liked = List<String>.from(user.liked);
    List<String> disliked = List<String>.from(user.disliked);
    if (liked.contains(viewModel.post.id)) {
      like = true;
    } else if (disliked.contains(viewModel.post.id)) {
      dislike = true;
    }
    try {
      return VotesState(viewModel, like, dislike);
    } catch (e) {
      return Container();
    }
  }
}

class VotesState extends StatefulWidget {
  final SinglePostViewModel viewModel;

  final bool like;
  final bool dislike;

  VotesState(this.viewModel, this.like, this.dislike);

  @override
  _VotesStateState createState() => _VotesStateState();
}

class _VotesStateState extends State<VotesState> {
  //good stackoverflow answer to storing likes efficiently
  //https://stackoverflow.com/a/51025186/11002034

  List<bool> _selections = [false, false];

  @override
  void initState() {
    super.initState();
    _selections = [widget.like, widget.dislike];
  }

  @override
  Widget build(BuildContext context) {
    int plus = 0;
    if (!widget.like && _selections[0]) {
      if (widget.dislike)
        plus = 2;
      else
        plus = 1;
    } else if (!widget.dislike && _selections[1]) {
      if (widget.like)
        plus = -2;
      else
        plus = -1;
    } else if (widget.like && !_selections[0]) {
      plus = -1;
    } else if (widget.dislike && !_selections[1]) {
      plus = 1;
    }
    return Row(
      children: [
        Text((widget.viewModel.votes + plus).toString()),
        ToggleButtons(
          children: [
            Icon(Icons.arrow_circle_up),
            Icon(Icons.arrow_circle_down),
          ],
          isSelected: _selections,
          onPressed: (index) {
            setUser(index == 0, _selections[index ^ 1]);
            setState(() {
              _selections[index] = !_selections[index];
              _selections[index ^ 1] = false;
            });
          },
          color: Theme.of(context).hintColor,
          renderBorder: false,
        ),
      ],
    );
  }

  Future<void> setUser(bool pressLike, bool change) async {
    if (pressLike) {
      if (_selections[0]) {
        widget.viewModel.like(false);
      } else {
        widget.viewModel.like(true);
      }
      if (change) {
        widget.viewModel.dislike(false);
      }
    } else {
      //press dislike
      if (_selections[1]) {
        widget.viewModel.dislike(false);
      } else {
        widget.viewModel.dislike(true);
      }
      if (change) {
        widget.viewModel.like(false);
      }
    }
  }
}

class FollowWidget extends StatefulWidget {
  final SinglePostViewModel viewModel;

  final List<String> followers;
  final String text;

  FollowWidget(this.text, this.viewModel, this.followers);

  @override
  _FollowWidgetState createState() => _FollowWidgetState();
}

class _FollowWidgetState extends State<FollowWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.post.userid != FirebaseAuth.instance.currentUser.uid) {
      return Container(
          color: Theme.of(context).cardColor,
          child: TextButton(
              onPressed: () async {
                if (widget.followers
                    .contains(FirebaseAuth.instance.currentUser.uid)) {
                  widget.followers
                      .remove(FirebaseAuth.instance.currentUser.uid);
                  await removeFromObject(
                      Collections.posts,
                      widget.viewModel.post.id,
                      'typeData.followers',
                      FirebaseAuth.instance.currentUser.uid);
                } else {
                  widget.followers.add(FirebaseAuth.instance.currentUser.uid);
                  await addToObject(
                      Collections.posts,
                      widget.viewModel.post.id,
                      'typeData.followers',
                      FirebaseAuth.instance.currentUser.uid);
                }
                setState(() {});
              },
              child: Row(
                children: [
                  Icon(widget.followers
                          .contains(FirebaseAuth.instance.currentUser.uid)
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off),
                  Text(widget.text),
                ],
              )));
    } else {
      return Container();
    }
  }
}

class FileDownloadWidget extends StatelessWidget {
  final String type;
  final String fileId;
  final SinglePostViewModel viewModel;

  FileDownloadWidget(this.fileId, this.type, this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: OutlinedButton(
        onPressed: () async {
          try {
            String url = await viewModel.getFileUrl(fileId);
            if (url != null) {
              Navigator.of(context).pushNamed(Routes.pdf, arguments: url);
            } else {
              showError('Could not open file', context);
            }
          } catch (e) {
            showError('Could not open file', context);
          }
        },
        child: Text('Open $type'),
      ),
    );
  }
}

class ImageHintWidget extends StatelessWidget {
  final String description;
  final String imageId;

  const ImageHintWidget({Key key, this.description, this.imageId});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (imageId != null)
          Container(
            child: Icon(
              Icons.image,
              color: Theme.of(context).hintColor,
              size: 25,
            ),
          ),
        Flexible(
          child: Text(description,
              style: Theme.of(context).textTheme.bodyText2,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class CommentWidget extends StatefulWidget {
  final bool answer;
  final String accepted;

  final SinglePostViewModel viewModel;

  const CommentWidget(this.viewModel, {@required this.answer, this.accepted});

  @override
  _CommentWidgetState createState() =>
      this.answer ? _AnswersWidgetState() : _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.viewModel.comments,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              for (Map<String, dynamic> data in snapshot.data)
                buildComment(context, data, widget.viewModel.post.id,
                    widget.viewModel.post.userid)
            ],
          );
        }
        return Container();
      },
    );
  }

  Comment buildComment(BuildContext context, Map<String, dynamic> data,
      String postId, String postUserId) {
    return Comment(
      username: data['username'],
      time: data['time'],
      text: data['text'],
      userid: data['userid'],
      postId: postId,
      commentId: data['id'],
    );
  }
}

class _AnswersWidgetState extends _CommentWidgetState {
  String accepted;

  @override
  void initState() {
    super.initState();
    accepted = widget.accepted;
  }

  @override
  Comment buildComment(BuildContext context, Map<String, dynamic> data,
      String postId, String postUserId) {
    return Answer(
      widget.viewModel,
      username: data['username'],
      time: data['time'],
      text: data['text'],
      userid: data['userid'],
      postId: postId,
      commentId: data['id'],
      accepted: accepted,
      postUserId: postUserId,
      onClick: (String id) {
        setState(() {
          accepted = id;
        });
      },
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String postId;
  final String commentId;
  final String userid;
  final String text;
  final int time;

  const Comment({
    Key key,
    @required this.username,
    @required this.userid,
    @required this.text,
    @required this.time,
    @required this.postId,
    @required this.commentId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildStart(),
                Expanded(
                  child: _buildComment(context),
                ),
              ],
            ),
          ),
          _createCommentMenu(),
        ],
      ),
    );
  }

  Widget _buildStart() {
    return Container();
  }

  Widget _buildComment(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              username,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              timeToText(time),
              style: TextStyle(
                fontSize: 10.0,
                color: Theme.of(context).accentColor,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          text,
        )
      ],
    );
  }

  Widget _createCommentMenu() {
    return FutureBuilder(
        future: fetchUser(FirebaseAuth.instance.currentUser.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          AcademicsUser user = snapshot.data;
          return PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).textTheme.bodyText2.color,
            ),
            onSelected: _commentActionSelect(context),
            itemBuilder: (BuildContext context) {
              return _reduceByUser(CommentActions.values.toList(), user.admin)
                  .map((CommentActions choice) {
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

  List<CommentActions> _reduceByUser(
      List<CommentActions> actions, bool isAdmin) {
    if (userid != FirebaseAuth.instance.currentUser.uid) {
      if (!isAdmin) {
        actions.remove(CommentActions.Delete);
      }
    } else {
      actions.remove(CommentActions.Report);
    }
    return actions;
  }

  Function(String) _commentActionSelect(BuildContext context) {
    return (String choice) async {
      if (choice == CommentActions.Report.toString()) {
        sendReport(Report(
          post: {
            'post': postId,
            'comment': commentId,
          },
          reason: await getReportReason(
              [ReportReason.commentInappropriate, ReportReason.commentSpam],
              context),
        ));
      } else if (choice == CommentActions.Delete.toString()) {
        deleteObject(Collections.posts, commentId,
            doc: postId, subCollection: Collections.comments);
      } else {}
    };
  }
}

class Answer extends Comment {
  final String accepted;
  final String postUserId;
  final Function onClick;
  final SinglePostViewModel viewModel;

  const Answer(
    this.viewModel, {
    Key key,
    @required username,
    @required userid,
    @required text,
    @required time,
    @required postId,
    @required commentId,
    @required this.accepted,
    @required this.postUserId,
    @required this.onClick,
  }) : super(
            username: username,
            time: time,
            text: text,
            userid: userid,
            postId: postId,
            commentId: commentId);

  @override
  Widget _buildStart() {
    if (accepted == null &&
        (postUserId == FirebaseAuth.instance.currentUser.uid)) {
      return SizedBox(
        width: 40,
        child: IconButton(
          onPressed: () {
            updateObject(Collections.posts, postId, 'typeData.accepted_answer',
                commentId);
            onClick(commentId);
            viewModel.notifyFollower(
                msg:
                    'An answer has been accepted on a question you wished to be notified on.',
                postToSend: viewModel.post.id);
          },
          icon: Icon(Icons.check_circle_outline),
        ),
      );
    } else if (accepted == commentId)
      return SizedBox(
        width: 40,
        child: IconButton(
          onPressed: () {
            if (postUserId == FirebaseAuth.instance.currentUser.uid) {
              updateObject(
                  Collections.posts, postId, 'typeData.accepted_answer', null);
              onClick(null);
            }
          },
          icon: Icon(Icons.check_circle),
          color: Colors.green,
        ),
      );
    return SizedBox(
      width: 40,
    );
  }
}

enum CommentActions {
  Delete,
  Report,
}

class UploadComment extends StatelessWidget {
  final String hint;
  final String postId;
  final ScrollController scrollController;

  const UploadComment({Key key, this.hint, this.postId, this.scrollController});

  @override
  Widget build(BuildContext context) {
    var textController = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            maxLength: 512,
            decoration: InputDecoration(hintText: hint),
            style: Theme.of(context).textTheme.bodyText2,
            controller: textController,
          ),
        ),
        IconButton(
            onPressed: () async {
              if (textController.text.trim().isNotEmpty) {
                String username;
                try {
                  username =
                      (await fetchUser(FirebaseAuth.instance.currentUser.uid))
                          .displayName;
                } catch (e) {
                  return;
                }
                uploadObject(
                    Collections.posts,
                    {
                      'userid': FirebaseAuth.instance.currentUser.uid,
                      'username': username,
                      'text': textController.text.trim(),
                      'time': DateTime.now().millisecondsSinceEpoch,
                    },
                    doc: postId,
                    subCollection: Collections.comments);
                textController.clear();
                scrollController.jumpTo(
                  scrollController.position.maxScrollExtent,
                );
              }
            },
            icon: Icon(Icons.send))
      ],
    );
  }
}

class TagsWidget extends StatelessWidget {
  final List<String> tags;

  const TagsWidget({Key key, this.tags});

  @override
  Widget build(BuildContext context) {
    if (tags.isNotEmpty)
      return Container(
        height: 22,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (String tag in tags)
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  margin: EdgeInsets.fromLTRB(0, 0, 4, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontSize: 10,
                    ),
                  ))
          ],
        ),
      );
    return Container();
  }
}

class SendFilePostWidget extends StatefulWidget {
  final SinglePostViewModel viewModel;

  const SendFilePostWidget(this.viewModel);

  @override
  _SendFilePostWidgetState createState() => _SendFilePostWidgetState();
}

class _SendFilePostWidgetState extends State<SendFilePostWidget> {
  String _selectedPost;

  @override
  Widget build(BuildContext context) {
    print('selected post: $_selectedPost');
    return Container(
      child: _selectedPost == null
          ? OutlinedButton(
              child: Text('Send File'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildPickDialog(context),
                );
              },
            )
          : Column(
              children: [
                FutureBuilder(
                  future: fetchPost(_selectedPost),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return PostBuilder(
                              post: snapshot.data, context: context)
                          .buildHintPost();
                    }
                    return Container();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      child: Text('Send'),
                      onPressed: () async {
                        showError('Sending post...', context);
                        await sendFile();
                      },
                    ),
                    Flexible(
                      child: OutlinedButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          setState(() {
                            _selectedPost = null;
                          });
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
      color: Theme.of(context).cardColor,
    );
  }

  Future sendFile() async {
    String user = widget.viewModel.post.userid;
    if (user != FirebaseAuth.instance.currentUser.uid) {
      sendMessage(
          Message(
              title: 'File Request',
              msg:
                  'Your Request was closed.\nA file has been uploaded by a user.\nSee post below.',
              time: DateTime.now().millisecondsSinceEpoch,
              sender: FirebaseAuth.instance.currentUser.uid,
              post: _selectedPost),
          user);
    }
    await widget.viewModel.notifyFollower(
        msg:
            'A file has been uploaded in a request you wished to be notified on.',
        postToSend: _selectedPost);

    PostBuilder(post: widget.viewModel.post, context: context).deletePost();
  }

  Widget _buildPickDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose File'),
      //content: const Text('Choose where to upload the image from'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            String id = (await Navigator.of(context)
                .pushNamed(Routes.uploadFile, arguments: widget.viewModel.post.folder)) as String;
            setState(() {
              _selectedPost = id;
            });
          },
          child: const Text('Upload new post'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            String id = (await Navigator.of(context)
                    .pushNamed(Routes.choosePost, arguments: [PostType.File]))
                as String;
            setState(() {
              _selectedPost = id;
            });
          },
          child: const Text('Pick existing file post'),
        ),
      ],
    );
  }
}
