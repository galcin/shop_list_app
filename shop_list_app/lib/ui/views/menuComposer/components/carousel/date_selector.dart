import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DateSelector extends StatefulWidget {
  final EdgeInsets padding;

  const DateSelector(
      {Key key, this.padding = const EdgeInsets.symmetric(vertical: 1.0)})
      : super(key: key);

  @override
  _DateSelector createState() => _DateSelector();
}

class _DateSelector extends State<DateSelector> {
  static const _daysPerScreen = 7;
  static const _fractionPerItem = 0.5 / _daysPerScreen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemSize = constraints.maxWidth * _fractionPerItem;

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              height: itemSize * 2 + widget.padding.vertical,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.amber])),
              ),
            ),
            IgnorePointer(
              child: Padding(
                padding: widget.padding,
                child: SizedBox(
                  width: itemSize,
                  height: itemSize,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(width: 3.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
