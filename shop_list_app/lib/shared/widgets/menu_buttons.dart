import 'package:flutter/material.dart';
import 'package:shop_list_app/shared/route_constants.dart';

class CustomMenuButtons extends StatelessWidget {
  const CustomMenuButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: settingsView,
          child: Row(
            children: [
              Icon(Icons.settings, color: Colors.black38),
              SizedBox(width: 15),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: aboutView,
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.black38),
              SizedBox(width: 15),
              Text('About'),
            ],
          ),
        ),
        const PopupMenuItem(
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
