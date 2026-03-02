import 'package:flutter/material.dart';
import 'package:shop_list_app/shared/route_constants.dart';

class CustomMenuButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: settingsView,
          child: Row(
            children: [
              Icon(Icons.settings, color: Colors.black38),
              SizedBox(width: 15),
              Text('Settings'),
            ],
          ),
        ),
        PopupMenuItem(
          value: aboutView,
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.black38),
              SizedBox(width: 15),
              Text('About'),
            ],
          ),
        ),
        PopupMenuItem(
          value: menuView,
          child: Row(
            children: [
              Icon(Icons.account_tree, color: Colors.black38),
              SizedBox(width: 15),
              Text('Menu'),
            ],
          ),
        )
      ],
      onSelected: (value) {
        Navigator.pushNamed(context, value);
      },
    ));
  }
}
