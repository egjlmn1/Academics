import 'package:academics/posts/postBuilder.dart';
import 'package:academics/user/model.dart';
import 'package:academics/user/viewModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../errors.dart';
import '../folders/folders.dart';
import '../routes.dart';

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
  var _selectedPage = 0;
  AcademicsUser user;

  UserViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = UserViewModel(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: viewModel.user,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            user = null;
          } else {
            user = snapshot.data;
          }
          return Column(
            children: [
              if (snapshot.hasData)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        (user != null && user.business)
                            ? Icons.business
                            : Icons.person,
                        size: 100,
                      ),
                      if (snapshot.hasError)
                        errorWidget('Error user', context)
                      else if (snapshot.hasData)
                        _buildDisplay(snapshot.data)
                    ],
                  ),
                ) else
                  SizedBox(height: 140,),
              Container(
                color: Theme.of(context).primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (_selectedPage == 0) {
                          return;
                        }
                        setState(() {
                          _selectedPage = 0;
                        });
                      },
                      child: Text('Posts', style: TextStyle(
                          decoration: (_selectedPage==0) ? TextDecoration.underline:TextDecoration.none,
                          color: Theme.of(context).accentColor,
                          fontSize: 20
                      ),),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_selectedPage == 1) {
                          return;
                        }
                        setState(() {
                          _selectedPage = 1;
                        });
                      },
                      child: Text('Following', style: TextStyle(
                          decoration: (_selectedPage==1) ? TextDecoration.underline:TextDecoration.none,
                          color: Theme.of(context).accentColor,
                          fontSize: 20
                      ),),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_selectedPage == 2) {
                          return;
                        }
                        setState(() {
                          _selectedPage = 2;
                        });
                      },
                      child: Text('Information', style: TextStyle(
                          decoration: (_selectedPage==2) ? TextDecoration.underline:TextDecoration.none,
                          color: Theme.of(context).accentColor,
                          fontSize: 20
                      ),),
                    ),
                  ],
                ),
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
        if (FirebaseAuth.instance.currentUser.uid == viewModel.userId)
          Container()
        else
          startChat()
      ],
    );
  }

  Widget startChat() {
    return TextButton(
      child: Text('Start a chat',
          style: TextStyle(
            fontSize: 30,
          )),
      onPressed: () async {
        String chatId = await viewModel.alreadyChatted();
        String docId;
        if (chatId != null) {
          docId = chatId;
        } else {
          docId = await viewModel.createChat([viewModel.userId, FirebaseAuth.instance.currentUser.uid]);
        }
        Navigator.of(context).pushNamed(Routes.chat, arguments: docId);
      },
    );
  }

  Widget createPage(AcademicsUser user) {
    if (_selectedPage == 0) {
      // your posts
      return Expanded(
        child: RefreshIndicator(
            onRefresh: _refreshData,
            child: PostListBuilder(posts: viewModel.getPosts(), context: context).buildPostPage()),
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
                          Routes.home, (r) => false,
                          arguments: {'folder': user.following[index]});
                    },
                    child: Folder(path: user.following[index]).build());
              }));
    } else {
      // information
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Name: ${user.displayName}'),
            ),
            if (viewModel.userId == FirebaseAuth.instance.currentUser.uid)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Email: ${user.email}'),
                    ShowUserEmail(viewModel, (user.showEmail)),
                  ],
                ),
              )
            else if (user.showEmail)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Email: ${user.email}'),
              ),
            if (user.department != null) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Department: ${user.department.split('/').last}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Credits: ${user.points}'),
            ),
          ],
        ),
      );
    }
  }

  Future _refreshData() async {
    print('refresh');
    setState(() {});
  }
}

class ShowUserEmail extends StatefulWidget {
  final UserViewModel viewModel;
  final bool show;

  ShowUserEmail(this.viewModel, this.show);

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
          widget.viewModel.showEmail(show);
        });
      },
      child: Text((show) ? 'Hide' : 'Show'),
    );
  }
}
