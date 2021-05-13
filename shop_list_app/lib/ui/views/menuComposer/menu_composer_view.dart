import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_list_app/ui/views/menuComposer/components/carousel/date_selector.dart';
import 'package:shop_list_app/ui/views/menuComposer/menu_container_component.dart';

class MenuComposerView extends StatefulWidget {
  @override
  _MenuComposerView createState() => _MenuComposerView();
}

class _MenuComposerView extends State<MenuComposerView> {
  DateTime _pickedDate = DateTime.now();
  Map<DateTime, Color> _coloredDates = {
    DateTime.now().add(Duration(days: 2)): Colors.blue,
    DateTime.now().subtract(Duration(days: 7)): Colors.red,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.calendar_today),
      ),
      appBar: AppBar(
          title: Text("Menu Composer"),
          bottom: PreferredSize(
            preferredSize: Size(15.0, 15.0),
            child: DateSelector(),
          )),
      body: Column(
        children: [
          MenuContainerComponent("Breakfast", null),
          MenuContainerComponent("Lunch", null),
          MenuContainerComponent("Dinner", null)
        ],
      ),
    );
  }
}
