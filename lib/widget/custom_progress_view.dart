import 'package:flutter/material.dart';

import '../theme_data.dart';

class CustomProgressView extends StatelessWidget {
  final bool inAsyncCall;
  final double opacity;
  final Color color;

  Widget progressIndicator;
  double progressValue;
  final bool dismissible;
  final Widget child;

  CustomProgressView({
    Key key,
    @required this.inAsyncCall,
    this.opacity = 0.3,
    this.color = Colors.grey,
    this.progressIndicator,
    this.progressValue,
    this.dismissible = false,
    this.child,
  })  : assert(inAsyncCall != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];

    if (child != null) {
      widgetList.add(child);
    }
    if (inAsyncCall) {
      Widget layOutProgressIndicator;
      progressIndicator = CircularProgressIndicator(
          value: progressValue,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor));
      layOutProgressIndicator = Center(child: progressIndicator);
      final modal = [
        new Opacity(
          child: new ModalBarrier(dismissible: dismissible, color: color),
          opacity: opacity,
        ),
        layOutProgressIndicator
      ];
      widgetList += modal;
    }
    return new Stack(
      children: widgetList,
    );
  }
}
