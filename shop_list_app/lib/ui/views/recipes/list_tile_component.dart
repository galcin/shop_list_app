import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_list_app/service/models/recipe.dart';

class ListTileComponent extends StatelessWidget {
  final Recipe item;
  ListTileComponent(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.image_not_supported_outlined),
      title: Text(item.name),
      subtitle: Text(item.description),
    );
  }
}
