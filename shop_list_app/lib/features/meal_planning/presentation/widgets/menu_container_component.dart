import 'package:flutter/material.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';

class MenuContainerComponent extends StatelessWidget {
  final String _label;
  // ignore: unused_field
  final Product _products;

  const MenuContainerComponent(this._label, this._products, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          right: 10.0, left: 10.0, top: 30.0, bottom: 10.0),
      child: InputDecorator(
        decoration: InputDecoration(
            labelText: _label,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
        child: const Text('element go here'),
      ),
    );
  }
}
