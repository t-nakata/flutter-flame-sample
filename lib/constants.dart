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

  static const drops = [
    dropRed,
    dropBlue,
    dropGreen,
    dropYellow,
    dropPurple,
    dropGold,
    dropSilver,
  ];
}
