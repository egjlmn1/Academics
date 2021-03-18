import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostSearch extends StatefulWidget {
  @override
  _PostSearchState createState() => _PostSearchState();
}

class _PostSearchState extends State<PostSearch> {

  List<String> previous_searches = ['test1', 'test1', 'test1', 'test1', 'test1', 'test1', 'test1', 'test1', 'test1', 'test1', ];
  List<String> recommended_searches = ['test1', 'test1', 'test1', 'test1',];

  TextEditingController _controller;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                FlatButton(
                    onPressed: () => {
                      Navigator.pop(context)
                    },
                    child: Icon(Icons.arrow_back)
                ),
                Expanded(
                  child: TextField(
                    onChanged: (search) {
                      print('search in post search changed to: $search');
                    },
                    onSubmitted: (search) {
                      print('search in post search submitted on: $search');
                    },
                  ),
                )
              ],
            ),
            Container(
              height: 200,
              child: ListView.builder(
                  itemCount: previous_searches.length,
                  physics: ScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return FlatButton(
                      onPressed: () => {

                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            Text(previous_searches[index]),
                            Icon(Icons.close),
                          ],
                        ),
                      ),
                    );
                  }
              ),
            ),
            Divider(
              color: Colors.black,
              height: 1,
            ),          Text('Recommended for you'),
            Expanded(
              child: ListView.builder(
                  itemCount: recommended_searches.length,
                  physics: ScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return FlatButton(
                      onPressed: () => {

                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.folder),
                            Text(previous_searches[index]),
                          ],
                        ),
                      ),
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
