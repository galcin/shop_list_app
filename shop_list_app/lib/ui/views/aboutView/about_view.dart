import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Application"),
      ),
      body: Container(
        child: Text("About application will be here"),
      ),
    );
  }
}
