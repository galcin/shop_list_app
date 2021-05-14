import 'package:flutter/cupertino.dart';
import 'package:shop_list_app/service/models/recipe.dart';
import 'package:shop_list_app/ui/views/menuComposer/menu_container_component.dart';

class TemplateSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MenuContainerComponent("Breakfast", new Recipe()),
        MenuContainerComponent("Lunch", new Recipe()),
        MenuContainerComponent("Dinner", new Recipe())
      ],
    );
  }
}
