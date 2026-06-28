import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double cornerRadius;
  final double cornerLength;
  final double strokeWidth;
  final Color cornerColor;

  ScannerOverlayPainter({
    required this.scanWindow,
    this.cornerRadius = 12.0,
    this.cornerLength = 24.0,
    this.strokeWidth = 4.0,
    required this.cornerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dessiner le fond d'assombrissement semi-transparent (Opacité 0.5)
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanWindow, Radius.circular(cornerRadius)));

    // Soustraction de la zone centrale claire (PathOperation.difference)
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(overlayPath, backgroundPaint);

    // 2. Dessiner les angles de guidage épais (Sky Blue)
    final cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final left = scanWindow.left;
    final top = scanWindow.top;
    final right = scanWindow.right;
    final bottom = scanWindow.bottom;

    // Angle haut-gauche
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top + cornerRadius)
        ..arcToPoint(Offset(left + cornerRadius, top), radius: Radius.circular(cornerRadius))
        ..lineTo(left + cornerLength, top),
      cornerPaint,
    );

    // Angle haut-droite
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLength, top)
        ..lineTo(right - cornerRadius, top)
        ..arcToPoint(Offset(right, top + cornerRadius), radius: Radius.circular(cornerRadius))
        ..lineTo(right, top + cornerLength),
      cornerPaint,
    );

    // Angle bas-gauche
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - cornerLength)
        ..lineTo(left, bottom - cornerRadius)
        ..arcToPoint(Offset(left + cornerRadius, bottom), radius: Radius.circular(cornerRadius))
        ..lineTo(left + cornerLength, bottom),
      cornerPaint,
    );

    // Angle bas-droite
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLength, bottom)
        ..lineTo(right - cornerRadius, bottom)
        ..arcToPoint(Offset(right, bottom - cornerRadius), radius: Radius.circular(cornerRadius))
        ..lineTo(right, bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow ||
        oldDelegate.cornerColor != cornerColor;
  }
}
