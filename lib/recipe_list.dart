import 'package:flutter/material.dart';
import 'package:newobjectdetectionyolov5/HomeScreen.dart';

class RecipeList extends StatefulWidget {
  var resultData;
  RecipeList({super.key, required this.resultData});

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var result = widget.resultData;
    print('RECIPE RESULT => $result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
      ),
    );
  }
}
