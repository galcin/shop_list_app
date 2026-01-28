import 'package:flutter/material.dart';
import 'package:shop_list_app/service/storage/local_db/app_database.dart';

class ListTileComponent extends StatelessWidget {
  final Product item;
  ListTileComponent(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        leading: Icon(Icons.image_not_supported_outlined),
        title: Text(item.name!),
        subtitle: Text(item.name!),
      ),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(20)),
    );
  }
}
