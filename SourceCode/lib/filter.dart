import 'package:academics/cloud/firebaseUtils.dart';
import 'package:academics/posts/model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChooseFilter extends StatefulWidget {

  final List<bool> initialFilter;

  const ChooseFilter({Key key, this.initialFilter}) : super(key: key);

  @override
  _ChooseFilterState createState() => _ChooseFilterState();
}

class _ChooseFilterState extends State<ChooseFilter> {

   List<bool> filter;

  @override
  void initState() {
    super.initState();
    filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return _buildFilterDialog(context);
  }

   Widget _buildFilterDialog(BuildContext context) {
     return AlertDialog(
       title: const Text('Filter posts'),
       content:ToggleButtons(
         direction: Axis.vertical,
         isSelected: filter,
         onPressed: (index) {
           setState(() {
             filter[index] = !filter[index];
             updateObject(Collections.users, FirebaseAuth.instance.currentUser.uid, 'filters', filter);
           });
         },
         children: [
           for (int i=0;i<filter.length;i++) Row(
             children: [
               Icon(filter[i] ? Icons.radio_button_checked:Icons.radio_button_off),
               Text(PostType.types[i]),
             ],
           ),

         ],
       ),
     );
   }
}
