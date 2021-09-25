import 'package:academics/errors.dart';
import 'package:academics/inbox/message.dart';
import 'package:academics/posts/postBuilder.dart';
import 'package:academics/posts/postUtils.dart';
import 'package:academics/posts/schemes.dart';
import 'package:academics/reports/report.dart';
import 'package:academics/reports/reportUtils.dart';
import 'package:academics/user/user.dart';
import 'package:academics/user/userUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../cloudUtils.dart';

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
                updateObject(
                    Collections.posts, widget.postId, 'typeData', widget.poll.toJson());
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
  final String image;

  ImageWidget(this.image);

  @override
  Widget build(BuildContext context) {
    return (image != null)
        ? FutureBuilder(
            future: FirebaseStorage.instance.ref(image).getDownloadURL(),
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
            })
        : Container();
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
  final String postId;

  const VoteWidget({
    Key key,
    @required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        child: FutureBuilder(
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
    if (liked.contains(postId)) {
      like = true;
    } else if (disliked.contains(postId)) {
      dislike = true;
    }
    try {
      Post post = await fetchPost(postId);
      return VotesState(
          postId, like, dislike, post.upVotes - post.downVotes, post.userid);
    } catch (e) {
      return Container();
    }
  }
}

class VotesState extends StatefulWidget {
  final String postId;
  final bool like;
  final bool dislike;
  final int votes;
  final String postUser;

  VotesState(this.postId, this.like, this.dislike, this.votes, this.postUser);

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
        Text((widget.votes + plus).toString()),
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
        like(false);
      } else {
        like(true);
      }
      if (change) {
        dislike(false);
      }
    } else {
      //press dislike
      if (_selections[1]) {
        dislike(false);
      } else {
        dislike(true);
      }
      if (change) {
        like(false);
      }
    }
  }

  void like(bool increase) async {
    if (increase) {
      addToObject(Collections.users, FirebaseAuth.instance.currentUser.uid,
          'liked', widget.postId);
      updateObject(Collections.posts, widget.postId, 'up_votes', FieldValue.increment(1));
      updateObject(Collections.users, widget.postUser, 'points',
          FieldValue.increment(1));
    } else {
      removeFromObject(Collections.users, FirebaseAuth.instance.currentUser.uid,
          'liked', widget.postId);
      updateObject(
          Collections.posts, widget.postId, 'up_votes', FieldValue.increment(-1));
      updateObject(Collections.users, widget.postUser, 'points',
          FieldValue.increment(-1));
    }
  }

  void dislike(bool increase) async {
    if (increase) {
      addToObject(Collections.users, FirebaseAuth.instance.currentUser.uid,
          'disliked', widget.postId);
      updateObject(
          Collections.posts, widget.postId, 'down_votes', FieldValue.increment(1));
      updateObject(Collections.users, widget.postUser, 'points',
          FieldValue.increment(-1));
    } else {
      removeFromObject(Collections.users, FirebaseAuth.instance.currentUser.uid,
          'disliked', widget.postId);
      updateObject(
          Collections.posts, widget.postId, 'down_votes', FieldValue.increment(-1));
      updateObject(Collections.users, widget.postUser, 'points',
          FieldValue.increment(1));
    }
  }
}

class FollowWidget extends StatefulWidget {
  final String postId;
  final String text;
  final List<String> followers;

  FollowWidget(this.text, this.postId, this.followers);

  @override
  _FollowWidgetState createState() => _FollowWidgetState();
}

class _FollowWidgetState extends State<FollowWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchPost(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.userid != FirebaseAuth.instance.currentUser.uid) {
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
                              widget.postId,
                              'typeData.followers',
                              FirebaseAuth.instance.currentUser.uid);
                        } else {
                          widget.followers
                              .add(FirebaseAuth.instance.currentUser.uid);
                          await addToObject(
                              Collections.posts,
                              widget.postId,
                              'typeData.followers',
                              FirebaseAuth.instance.currentUser.uid);
                        }
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Icon(widget.followers.contains(
                                  FirebaseAuth.instance.currentUser.uid)
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off),
                          Text(widget.text),
                        ],
                      )));
            }
          }
          return Container();
        });
  }
}

class FileDownloadWidget extends StatelessWidget {
  final String fileId;
  final String type;

  FileDownloadWidget(this.fileId, this.type);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: TextButton(
        onPressed: () async {
          try {
            String url =  await FirebaseStorage.instance.ref(fileId).getDownloadURL();
            if (url != null) {
              Navigator.of(context).pushNamed('/pdf',
                  arguments:url);
            } else {
              showError('Could not open file', context);
            }
          } catch(e) {
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
              size: 15,
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
  final String postId;
  final String accepted;

  const CommentWidget(
      {Key key, @required this.answer, @required this.postId, this.accepted})
      : super(key: key);

  @override
  _CommentWidgetState createState() =>
      this.answer ? _AnswersWidgetState() : _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
          future: fetchPost(widget.postId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
            } else if(snapshot.hasData) {
              Post post = snapshot.data;
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(Collections.posts)
                    .doc(widget.postId)
                    .collection(Collections.comments)
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        for (QueryDocumentSnapshot doc in snapshot.data.docs)
                          buildComment(context, doc, widget.postId, post.userid)
                      ],
                    );
                  }
                  return Container();
                },
              );
            }
            return Container();
          }
        )

        );
  }

  Comment buildComment(
      BuildContext context, QueryDocumentSnapshot item, String postId, String postUserId) {
    Map<String, dynamic> data = item.data();
    return Comment(
      username: data['username'],
      time: data['time'],
      text: data['text'],
      userid: data['userid'],
      postId: postId,
      commentId: item.id,
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
  Comment buildComment(BuildContext context, QueryDocumentSnapshot item, String postId, String postUserId) {
    Map<String, dynamic> data = item.data();
    return Answer(
      username: data['username'],
      time: data['time'],
      text: data['text'],
      userid: data['userid'],
      postId: postId,
      commentId: item.id,
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

  const Answer({
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
            updateObject(
                Collections.posts, postId, 'typeData.accepted_answer', commentId);
            onClick(commentId);
            notifyFollower(
                postFollowed: postId,
                msg:
                    'An answer has been accepted on a question you wished to be notified on.',
                postToSend: postId);
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
              updateObject(Collections.posts, postId, 'typeData.accepted_answer', null);
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
  final String post;

  const SendFilePostWidget({Key key, @required this.post});

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
          : Row(
              children: [
                Expanded(
                  child: FutureBuilder(
                    future: fetchPost(_selectedPost),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return PostCreator(
                                post: snapshot.data, context: context)
                            .buildHintPost();
                      }
                      return Container();
                    },
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedPost = null;
                          });
                        },
                      ),
                      Flexible(
                        child: TextButton(
                          child: Text('send'),
                          onPressed: () async {
                            showError('Sending post...', context);
                            await sendFile();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      color: Theme.of(context).cardColor,
    );
  }

  Future sendFile() async {
    Post post = await fetchPost(widget.post);
    String user = post.userid;
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
    await notifyFollower(
        postFollowed: post.id,
        msg:
            'A file has been uploaded in a request you wished to be notified on.',
        postToSend: _selectedPost);

    PostCreator(post: post, context: context).deletePost();
  }

  Widget _buildPickDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose File'),
      //content: const Text('Choose where to upload the image from'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            String id = (await Navigator.of(context).pushNamed('/upload_file'))
                as String;
            setState(() {
              _selectedPost = id;
            });
          },
          child: const Text('Upload new post'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            String id = (await Navigator.of(context).pushNamed('/choose_post',
                arguments: [PostType.File])) as String;
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

Future<void> notifyFollower(
    {@required String postFollowed,
    @required String msg,
    String postToSend}) async {
  List<String> followers =
      (await fetchPost(postFollowed)).typeData.getFollowers();
  for (String follower in followers) {
    sendMessage(
        Message(
            title: 'Post update',
            msg: msg,
            time: DateTime.now().millisecondsSinceEpoch,
            sender: null,
            post: postToSend),
        follower);
  }
  return updateObject(Collections.posts, postFollowed, 'typeData.followers', []);
}
