import 'package:flutter/material.dart';

class CropGridPainter extends CustomPainter {
  const CropGridPainter(
    this.rect, {
    this.radius = 0,
    this.showGrid = true,
    this.showCenterRects = true,
  });

  final Rect rect;

  final double radius;
  final bool showGrid, showCenterRects;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    if (showGrid) {
      _drawGrid(canvas, size);
      _drawBoundaries(canvas, size);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.black45;

    // when scaling, the positions might not be exactly accurates
    // so add an extra margin to be sure to overlay all video
    final margin = showGrid ? 0.0 : 1.0;

    // extract [rect] area from the canvas
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addRect(Rect.fromLTWH(-margin, -margin, size.width + margin * 2,
              size.height + margin * 2)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
          ..close(),
      ),
      paint,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final int gridSize = 3;
    final Paint paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.white;

    for (int i = 0; i <= gridSize; i++) {
      double rowDy = rect.topLeft.dy + (rect.height / gridSize) * i;
      double columnDx = rect.topLeft.dx + (rect.width / gridSize) * i;
      if (i == 0 || i == gridSize) {
        paint.color = Colors.white;
        canvas.drawLine(
          Offset(columnDx, rect.topLeft.dy),
          Offset(columnDx, rect.bottomLeft.dy),
          paint,
        );
        canvas.drawLine(
          Offset(rect.topLeft.dx, rowDy),
          Offset(rect.topRight.dx, rowDy),
          paint,
        );
      } else {
        paint.color = Colors.white.withOpacity(0.5);
        canvas.drawLine(
          Offset(columnDx, rect.topLeft.dy),
          Offset(columnDx, rect.bottomLeft.dy),
          paint,
        );
        drawDashedLine(canvas, paint, Offset(columnDx, rect.topLeft.dy),
            Offset(columnDx, rect.bottomLeft.dy), 5, 5);
        canvas.drawLine(
          Offset(rect.topLeft.dx, rowDy),
          Offset(rect.topRight.dx, rowDy),
          paint,
        );
      }
    }
  }

  void drawDashedLine(Canvas canvas1, Paint paint, Offset start, Offset end,
      double dashWidth, double dashSpace) {
    final path = Path();
    path.moveTo(start.dx, end.dy);
    path.lineTo(end.dx, end.dy);

    // final distance = end.dx - start.dx;
    // final dashCount = (distance / (dashWidth + dashSpace)).floor();

    // final dxStep = (end.dx - start.dx) / dashCount;
    // final dyStep = (end.dy - start.dy) / dashCount;

    // for (var i = 0; i < dashCount; ++i) {
    //   final from = Offset(start.dx + i * dxStep, start.dy + i * dyStep);
    //   final to =
    //       Offset(start.dx + (i + 1) * dxStep, start.dy + (i + 1) * dyStep);
    //   path.lineTo(from.dx, from.dy);
    //   path.moveTo(to.dx, to.dy);
    // }

    canvas1.drawPath(path, paint);
  }

  Paint getPaintFromBoundary() {
    return Paint()..color = Colors.white;
  }

  void _drawBoundaries(Canvas canvas, Size size) {
    final double width = 2;
    final double length = 20;

    //----//
    //EDGE//
    //----//
    // TOP LEFT |-
    final topLeft = rect.topLeft.translate(-width, -width);
    canvas.drawRect(
      Rect.fromPoints(
        topLeft,
        topLeft + Offset(width, length),
      ),
      getPaintFromBoundary(),
    );
    canvas.drawRect(
      Rect.fromPoints(
        topLeft,
        topLeft + Offset(length, width),
      ),
      getPaintFromBoundary(),
    );

    // TOP RIGHT -|
    final topRight = rect.topRight.translate(width, -width);
    canvas.drawRect(
      Rect.fromPoints(
        topRight - Offset(length, 0.0),
        topRight + Offset(0.0, width),
      ),
      getPaintFromBoundary(),
    );
    canvas.drawRect(
      Rect.fromPoints(
        topRight,
        topRight - Offset(width, -length),
      ),
      getPaintFromBoundary(),
    );

    // BOTTOM RIGHT _|
    final bottomRight = rect.bottomRight.translate(width, width);

    canvas.drawRect(
      Rect.fromPoints(
        bottomRight - Offset(width, length),
        bottomRight,
      ),
      getPaintFromBoundary(),
    );
    canvas.drawRect(
      Rect.fromPoints(
        bottomRight,
        bottomRight - Offset(length, width),
      ),
      getPaintFromBoundary(),
    );

    // BOTTOM LEFT |_
    final bottomLeft = rect.bottomLeft.translate(-width, width);

    canvas.drawRect(
      Rect.fromPoints(
        bottomLeft - Offset(-width, length),
        bottomLeft,
      ),
      getPaintFromBoundary(),
    );
    canvas.drawRect(
      Rect.fromPoints(
        bottomLeft,
        bottomLeft + Offset(length, -width),
      ),
      getPaintFromBoundary(),
    );

    //------//
    //CENTER//
    //------//
    // if (showCenterRects) {
    //   //TOPCENTER
    //   canvas.drawRect(
    //     Rect.fromPoints(
    //       rect.topCenter + Offset(-length / 2, 0.0),
    //       rect.topCenter + Offset(length / 2, width),
    //     ),
    //     getPaintFromBoundary(),
    //   );

    //   //BOTTOMCENTER
    //   canvas.drawRect(
    //     Rect.fromPoints(
    //       rect.bottomCenter + Offset(-length / 2, 0.0),
    //       rect.bottomCenter + Offset(length / 2, -width),
    //     ),
    //     getPaintFromBoundary(),
    //   );

    //   //CENTERLEFT
    //   canvas.drawRect(
    //     Rect.fromPoints(
    //       rect.centerLeft + Offset(0.0, -length / 2),
    //       rect.centerLeft + Offset(width, length / 2),
    //     ),
    //     getPaintFromBoundary(),
    //   );

    //   //CENTERRIGHT
    //   canvas.drawRect(
    //     Rect.fromPoints(
    //       rect.centerRight + Offset(-width, -length / 2),
    //       rect.centerRight + Offset(0.0, length / 2),
    //     ),
    //     getPaintFromBoundary(),
    //   );
    // }
  }

  @override
  bool shouldRepaint(CropGridPainter oldDelegate) =>
      oldDelegate.rect != rect ||
      oldDelegate.radius != radius ||
      oldDelegate.showCenterRects != showCenterRects ||
      oldDelegate.showGrid != showGrid;

  @override
  bool shouldRebuildSemantics(CropGridPainter oldDelegate) => false;
}
