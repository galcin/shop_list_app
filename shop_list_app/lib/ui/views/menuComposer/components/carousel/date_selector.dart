import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'carousel_flow_delegate.dart';

class DateSelector extends StatefulWidget {
  final EdgeInsets padding;
  final void Function(int selectedDay) onFilterChanged;
  final List<int> filters;

  const DateSelector(
      {Key? key,
      this.padding = const EdgeInsets.symmetric(vertical: 1.0),
      required this.filters,
      required this.onFilterChanged})
      : super(key: key);

  @override
  _DateSelector createState() => _DateSelector();
}

class _DateSelector extends State<DateSelector> {
  static const _daysPerScreen = 7;
  static const _fractionPerItem = 0.5 / _daysPerScreen;
  late final PageController _controller;
  late int _page;

  int get filterCount => widget.filters.length;

  @override
  void initState() {
    super.initState();
    _page = 0;
    _controller =
        PageController(initialPage: _page, viewportFraction: _fractionPerItem);
    _controller.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = (_controller.page ?? 0).round();
    if (_page != page) {
      _page = page;
      widget.onFilterChanged(widget.filters[page]);
    }
  }

  void _onFilterTapped(int index) {
    _controller.animateToPage(index,
        duration: Duration(microseconds: 450), curve: Curves.ease);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
        controller: _controller,
        axisDirection: AxisDirection.right,
        physics: PageScrollPhysics(),
        viewportBuilder: (context, viewportOffset) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final itemSize = constraints.maxWidth * _fractionPerItem;
              viewportOffset
                ..applyViewportDimension(constraints.maxWidth)
                ..applyContentDimensions(0.0, itemSize * (filterCount - 1));

              return Stack(
                alignment: Alignment.bottomCenter,
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
                  //carousel
                  Container(
                    height: itemSize,
                    margin: widget.padding,
                    child: Flow(
                      delegate: CarouselFlowDelegate(
                        viewportOffset: viewportOffset,
                        filtersPerScreen: _daysPerScreen,
                      ),
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
        });
  }
}
