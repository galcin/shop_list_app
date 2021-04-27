import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuComposerView extends StatelessWidget{
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu Composer"),),
      body: Container(
        child: Text("Composer go here"),
      ),
    );
  }
}
