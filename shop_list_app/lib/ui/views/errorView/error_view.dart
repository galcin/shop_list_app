import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Error Page"),
      ),
      body: Container(
        child: Text("Error should be here"),
      ),
    );
  }
}
