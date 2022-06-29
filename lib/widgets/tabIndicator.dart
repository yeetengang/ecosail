import 'package:flutter/material.dart';

class CircleTabIndicator extends Decoration {
  final Color color; //Color of circle
  double radius; //Radius of circle
  CircleTabIndicator({required this.color, required this.radius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CirclePainter(color: color, radius: radius);
  }
}

class _CirclePainter extends BoxPainter {
  final Color color; //Color of circle
  double radius; //Radius of circle
  _CirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Paint _paint = Paint();
    _paint.color = color;
    _paint.isAntiAlias = true;
    //configuration allow to access the details of the element that use this paint
    final Offset circleOffset = Offset(configuration.size!.width/2 - radius/2, configuration.size!.height - radius);

    canvas.drawCircle(offset+circleOffset, radius, _paint);
  }
}