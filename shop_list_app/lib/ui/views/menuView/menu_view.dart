import 'package:flutter/material.dart';

class MenuView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Menu Program"),
      ),
      body: Container(
        child: Text("Generate menu"),
      ),
    );
  }
}
