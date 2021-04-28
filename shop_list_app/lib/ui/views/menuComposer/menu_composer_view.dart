import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inline_calender/inline_calender.dart';

class MenuComposerView extends StatefulWidget{
  @override
  _MenuComposerView createState()=>_MenuComposerView();
}
class _MenuComposerView extends State<MenuComposerView> {
  InlineCalenderModel _controller;
  DateTime _pickedDate = DateTime.now();
  Map<DateTime, Color> _coloredDates = {
    DateTime.now().add(Duration(days: 2)): Colors.blue,
    DateTime.now().subtract(Duration(days: 7)): Colors.red,
  };
  @override
  void initState(){
      _controller = InlineCalenderModel(
      defaultSelectedDate: _pickedDate,
      onChange: (DateTime date) => print(date),
    );
    _controller.setColoredDates(_coloredDates) ;
    super.initState();
  }

  @override
  void dispose() {
    print('dispose');
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _controller.selectedDate =
                _controller.selectedDate.add(DateTime.now().difference(_controller.selectedDate));
          },
          child: Icon(Icons.calendar_today),
        ),
      appBar: AppBar(
        title: Text("Menu Composer"),
        bottom: InlineCalender(
          controller: _controller,
          locale: Locale('en_GB'),
          isShamsi: false,
          middleWeekday: DateTime.now().weekday,
        ),
      ),
      body: Container(
        child: Text("Composer go here"),
      ),
    );
  }
}
