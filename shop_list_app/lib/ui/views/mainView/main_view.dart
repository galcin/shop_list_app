import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_list_app/ui/route_constants.dart';

class MainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: settingsView,
                child: Text('Settings'),
              ),
              PopupMenuItem(
                value: aboutView,
                child: Text('About'),
              )
            ],
            onSelected: (value) {
              Navigator.pushNamed(context, value);
            },
          )
        ],
      ),
    );
  }
}
