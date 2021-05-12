import 'dart:async';
import 'dart:convert';

import 'package:academics/postUtils.dart';
import 'package:academics/schemes.dart';
import 'package:flutter/material.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                TextButton(
                  onPressed: () => {
                    Navigator.pushNamed(context, '/post_search')
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        Text('search'),
                        Icon(Icons.search),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black,
                  height: 1,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: Row(
                    children: [
                      Text('test'),
                    ],
                  ),
                )
              ]
            ),
          ),
          Expanded(
            child: fetchPosts('home_posts'),
          ),
        ],
      ),
    );
  }
}
