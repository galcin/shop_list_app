import 'package:flutter/material.dart';
import 'package:shop_list_app/features/meal_planning/presentation/widgets/carousel/date_selector.dart';
import 'package:shop_list_app/features/meal_planning/presentation/widgets/carousel/template_selector.dart';

class MenuComposerView extends StatefulWidget {
  @override
  _MenuComposerView createState() => _MenuComposerView();
}

class _MenuComposerView extends State<MenuComposerView> {
  final _days = [1, ...List.generate(7, (index) => index++)];
  final _selectedDay = ValueNotifier<int>(1);

  _onSelecteDay(int day) {
    _selectedDay.value = day;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blueAccent,
      child: Stack(
        children: [
          Positioned.fill(
            child: TemplateSelector(),
          ),
          Positioned.fill(
            left: 0,
            right: 0,
            bottom: 0,
            child: DateSelector(
              onFilterChanged: _onSelecteDay,
              filters: _days,
            ),
          )
        ],
      ),
    );
  }
}
