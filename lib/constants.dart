import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Palette {
  static const PaletteEntry white = BasicPalette.white;
  static const PaletteEntry red = PaletteEntry(Color(0xFFFF0000));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF0000FF));
}

class ImagePath {
  static const dropRed = "ball01_red.png";
  static const dropBlue = "ball05_blue.png";
  static const dropGreen = "ball06_green.png";
  static const dropYellow = "ball03_yellow.png";
  static const dropPurple = "ball07_purple.png";
  static const dropGold = "ball11_gold.png";
  static const dropSilver = "ball12_silver.png";
  static const blockPink = "block01_pink.png";

  static const drops = [
    dropRed,
    dropBlue,
    dropGreen,
    dropYellow,
    dropPurple,
    blockPink,
    dropGold,
    dropSilver,
  ];

  static String getPath(int index) {
    return drops[index];
  }
}

class Paints {

  static TextPaint large = TextPaint(
    config: const TextPaintConfig(
      fontSize: 48.0,
      fontFamily: 'Awesome Font',
    ),
  );

  static final Paint white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint grey = Paint()..color = const Color(0xFFA5A5A5);
  static final Paint black = Paint()..color = const Color(0xFF000000);

}