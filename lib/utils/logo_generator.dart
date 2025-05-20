import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> generateLogo() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(200, 200);
  final paint = Paint()
    ..color = const Color(0xFF1CC29F)
    ..style = PaintingStyle.fill;

  // Draw circle
  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2),
    size.width / 2,
    paint,
  );

  // Draw text
  final textPainter = TextPainter(
    text: const TextSpan(
      text: 'S',
      style: TextStyle(
        color: Colors.white,
        fontSize: 100,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    ),
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/logo.png');
  await file.writeAsBytes(buffer);
} 