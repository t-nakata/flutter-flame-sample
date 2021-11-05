import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame/puzzle_game.dart';

void main() async {
  runApp(GameWidget(game: PuzzleGame()));
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();
}
