import 'package:flutter/cupertino.dart';
import 'package:shop_list_app/features/shopping/domain/entities/product.dart';
import '../menu_container_component.dart';

class TemplateSelector extends StatelessWidget {
  const TemplateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MenuContainerComponent('Breakfast', Product()),
        MenuContainerComponent('Lunch', Product()),
        MenuContainerComponent('Dinner', Product())
      ],
    );
  }
}
