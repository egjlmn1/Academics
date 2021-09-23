import 'package:academics/chat/chatUtils.dart';
import 'package:academics/posts/postUtils.dart';
import 'package:academics/user/user.dart';
import 'package:academics/user/userUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../cloudUtils.dart';
import '../errors.dart';
import '../folders/folders.dart';

class UserProfile extends StatelessWidget {
  final String id;

  const UserProfile({Key key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: ProfilePage(id: id)),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String id;

  ProfilePage({@required this.id});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userid;
  var _selectedPage = 0;
  AcademicsUser user;

  @override
  void initState() {
    super.initState();
    _userid = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchUser(_userid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            user = null;
          } else {
            user = snapshot.data;
          }
          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      (user != null && user.business)
                          ? Icons.business
                          : Icons.person,
                      size: 100,
                    ),
                    Column(
                      children: [
                        if (snapshot.hasError)
                          errorWidget('Error user', context)
                        else if (snapshot.hasData)
                          _buildDisplay(snapshot.data)
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: Text('Posts'),
                    onPressed: () {
                      if (_selectedPage == 0) {
                        return;
                      }
                      setState(() {
                        _selectedPage = 0;
                      });
                    },
                  ),
                  TextButton(
                    child: Text('Following'),
                    onPressed: () {
                      if (_selectedPage == 1) {
                        return;
                      }
                      setState(() {
                        _selectedPage = 1;
                      });
                    },
                  ),
                  TextButton(
                    child: Text('Information'),
                    onPressed: () {
                      if (_selectedPage == 2) {
                        return;
                      }
                      setState(() {
                        _selectedPage = 2;
                      });
                    },
                  )
                ],
              ),
              if (!snapshot.hasError && snapshot.hasData)
                createPage(snapshot.data),
            ],
          );
        });
  }

  Widget _buildDisplay(AcademicsUser user) {
    return Column(
      children: [
        Text(
          user.displayName,
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        if (FirebaseAuth.instance.currentUser.uid == _userid)
          Container()
        else
          startChat()
      ],
    );
  }

  Future<String> alreadyChatted() async {
    for (String chatId in (await FirebaseFirestore.instance
            .collection(Collections.users)
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection(Collections.chat)
            .get())
        .docs
        .map((e) => e.id)) {
      List<String> users =
          List.from((await getDocSnapshot(Collections.chat, chatId)).get('users'));
      if (users.contains(_userid)) {
        return chatId;
      }
    }
    return null;
  }

  Widget startChat() {
    Future<String> didChat = alreadyChatted();
    return TextButton(
      child: Text('Start a chat',
          style: TextStyle(
            fontSize: 30,
          )),
      onPressed: () async {
        String chatId = await didChat;
        String docId;
        if (chatId != null) {
          docId = chatId;
        } else {
          docId = await createChat([_userid, FirebaseAuth.instance.currentUser.uid]);
        }
        Navigator.of(context).pushNamed('/chat', arguments: docId);
      },
    );
  }

  Widget completeProfile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('Your profile is 20% done'),
        TextButton(
          child: Text('continue'),
          onPressed: () {},
        )
      ],
    );
  }

  Widget createPage(AcademicsUser user) {
    if (_selectedPage == 0) {
      // your posts
      return Expanded(
        child: RefreshIndicator(
            onRefresh: _refreshData,
            child: createPostPage(fetchPosts(user: user.id), context)),
      );
    } else if (_selectedPage == 1) {
      // following
      return Expanded(
          child: ListView.builder(
              itemCount: user.following.length,
              itemBuilder: (BuildContext context, int index) {
                return TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home', (r) => false,
                          arguments: {'folder': user.following[index]});
                    },
                    child: Folder(path: user.following[index]).build());
              }));
    } else {
      // information
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${user.displayName}'),
          if (_userid == FirebaseAuth.instance.currentUser.uid)
            Row(
              children: [
                Text('Email: ${user.email}'),
                ShowUserEmail(_userid, (user.showEmail)),
              ],
            )
          else if (user.showEmail)
            Text('Email: ${user.email}'),
          if (user.department != null) Text(user.department)
        ],
      );
    }
  }

  Future _refreshData() async {
    print('refresh');
    setState(() {});
  }
}

class ShowUserEmail extends StatefulWidget {
  final String id;
  final bool show;

  ShowUserEmail(this.id, this.show);

  @override
  _ShowUserEmailState createState() => _ShowUserEmailState();
}

class _ShowUserEmailState extends State<ShowUserEmail> {
  bool show;

  @override
  void initState() {
    super.initState();
    this.show = widget.show;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          show = !show;
          updateObject(Collections.users, widget.id, 'show_email', show);
        });
      },
      child: Text((show) ? 'Hide' : 'Show'),
    );
  }
}
