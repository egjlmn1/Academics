import 'package:academics/cloudUtils.dart';
import 'package:academics/errors.dart';
import 'package:academics/posts/postBuilder.dart';
import 'package:academics/posts/postUtils.dart';
import 'package:academics/posts/schemes.dart';
import 'package:academics/reports/report.dart';
import 'package:academics/reports/reportUtils.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: getReports(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('ReportsPage ${snapshot.error}');
            return errorWidget('Error fetching reports', context);
          } if (snapshot.hasData) {
            return buildItems(snapshot.data);
          }
          return Container();
        },
      ),
    );
  }

  Widget buildItems(List<Report> reportsList) {
    return FutureBuilder(
      future: fetchPosts(ids: List<String>.from(reportsList.map((report)=>report.post['post']))),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Post> posts = snapshot.data;
          print(posts);
          var reports = [for (int i=0; i<reportsList.length;i++) if (posts.any((element) =>  element.id==reportsList[i].post['post'])) {reportsList[i]: posts.firstWhere((element) => element.id==reportsList[i].post['post'])}];
          reports.sort((a,b)=>b.entries.first.key.amount.compareTo(a.entries.first.key.amount));
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return TextButton(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(reports[index].entries.first.key.reason, style: Theme.of(context).textTheme.subtitle1,),
                          TextButton(
                            child: Text('Fixed'),
                            onPressed: () async {
                              await deleteObject('reports', reports[index].entries.first.key.id);
                              setState(() {

                              });
                            },
                          )
                        ],
                      ),
                      PostCreator(post: reports[index].entries.first.value, context: context).buildHintPost(),
                    ],
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/post_page', arguments: reports[index].entries.first.value.id);
                },
              );
            },
          );
        } if (snapshot.hasError) {
          return errorWidget('Error occurred while fetching reports', context);
        }
        return Container();
      },
    );
  }
}
