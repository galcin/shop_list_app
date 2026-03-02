import 'package:flutter/material.dart';
import 'package:shop_list_app/features/shopping/domain/entities/product.dart';

class MenuContainerComponent extends StatelessWidget {
  final String _label;
  final Product _products;

  MenuContainerComponent(this._label, this._products);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10.0, left: 10.0, top: 30.0, bottom: 10.0),
      child: Container(
        child: InputDecorator(
          decoration: InputDecoration(
              labelText: _label,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
          child: Text('element go here'),
        ),
      ),
    );
  }
}
