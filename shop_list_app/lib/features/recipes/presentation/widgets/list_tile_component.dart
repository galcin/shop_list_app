import 'package:flutter/material.dart';
import 'package:shop_list_app/core/database/app_database.dart';

class ListTileComponent extends StatelessWidget {
  final Product item;
  const ListTileComponent(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: const Icon(Icons.image_not_supported_outlined),
        title: Text(item.name),
        subtitle: Text(item.name),
      ),
    );
  }
}
