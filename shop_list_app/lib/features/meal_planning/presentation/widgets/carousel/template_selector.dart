import 'package:flutter/cupertino.dart';
import 'package:shop_list_app/features/shopping/domain/entities/product.dart';
import '../menu_container_component.dart';

class TemplateSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MenuContainerComponent("Breakfast", new Product()),
        MenuContainerComponent("Lunch", new Product()),
        MenuContainerComponent("Dinner", new Product())
      ],
    );
  }
}
