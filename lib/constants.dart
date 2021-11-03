import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Palette {
  static const PaletteEntry white = BasicPalette.white;
  static const PaletteEntry red = PaletteEntry(Color(0xFFFF0000));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF0000FF));
}

class ImagePath {
  static const dropRed = "drop_red.png";
  static const dropBlue = "drop_blue.png";
  static const dropGreen = "drop_green.png";
  static const dropYellow = "drop_yellow.png";
  static const dropPurple = "drop_purple.png";
  static const blockPink = "block_pink.png";

  static const drops = [
    dropRed,
    dropBlue,
    dropGreen,
    dropYellow,
    dropPurple,
    blockPink,
  ];

  static String getPath(int index) {
    return drops[index];
  }
}

class Paints {

  static TextPaint large = TextPaint(
    config: const TextPaintConfig(
      fontSize: 36.0,
      fontFamily: 'Awesome Font',
    ),
  );

  static TextPaint normal = TextPaint(
    config: const TextPaintConfig(
      fontSize: 24.0,
      fontFamily: 'Awesome Font',
    ),
  );

  static final Paint white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint grey = Paint()..color = const Color(0xFFA5A5A5);
  static final Paint black = Paint()..color = const Color(0xFF000000);

}