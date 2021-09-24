import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostSearch extends StatefulWidget {
  @override
  _PostSearchState createState() => _PostSearchState();
}

class _PostSearchState extends State<PostSearch> {
  Future<List<String>> _previousSearches;

  TextEditingController _controller;

  void initState() {
    super.initState();
    _previousSearches = loadSearches();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              maxLength: 64,
              onSubmitted: (search) {
                addSearch(search.trim());
                Navigator.of(context).pop(search.trim());
              },
            ),
            Expanded(
              child: FutureBuilder(
                future: _previousSearches,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        physics: ScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  addSearch(snapshot.data[index]);
                                  Navigator.of(context).pop(snapshot.data[index]);
                                },
                                child: Container(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Text(snapshot.data[index]),
                                ),
                              ),
                              IconButton(onPressed: () {
                                _previousSearches = removeSearch(snapshot.data[index]);
                                setState(() {

                                });
                              }, icon: Icon(Icons.close))
                            ],
                          );
                        });
                  }
                  return Container();
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> removeSearch(String search) async {
    List<String> previous = await _previousSearches;
    previous.remove(search);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('previousSearch', previous);
    return previous;
  }

  void addSearch(String search) async {
    List<String> previous = await _previousSearches;
    if (previous.contains(search)) {
      previous.remove(search);
    }
    previous.insert(0, search);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('previousSearch', previous);
  }

  Future<List<String>> loadSearches() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList('previousSearch') ?? [];
    return searches;
  }

}
