
import 'dart:ui';

import 'package:flutter/material.dart';

class DiagonalClipper extends CustomClipper<Path> {
  final int part;

  DiagonalClipper({required this.part});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (part == 1) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
      path.close();
    } else if (part == 2) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

