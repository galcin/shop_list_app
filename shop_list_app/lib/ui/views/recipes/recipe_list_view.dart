import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecipeListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe list"),
      ),
      body: Text("List view here"),
    );
  }
}
