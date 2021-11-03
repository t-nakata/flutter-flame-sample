import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/widgets.dart';
import 'package:flutter_flame/constants.dart';
import 'package:flutter_flame/puzzle_game.dart';
import 'package:flutter_flame/ui/game/drop_field.dart';

class GameScreen extends PositionComponent with HasGameRef<PuzzleGame> {
  final ScreenCallback screenCallback;
  late TextComponent titleTextComponent;

  late DropField dropField;
  double dropSize = 10;
  List<List<int>> dropInfo = [[]];

  GameScreen(this.screenCallback) {
    anchor = Anchor.topLeft;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    titleTextComponent = TextComponent(
      "ゲーム画面",
      textRenderer: Paints.large,
    )
          ..anchor = Anchor.center
          ..position = Vector2(gameRef.size.x / 2, gameRef.size.y / 10)
        //
        ;

    createDropInfo();
    dropField = DropField(dropSize, gameRef);
    await dropField.init();

    add(titleTextComponent);
    add(dropField);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    dropSize = gameSize.x / 6;
  }

  void createDropInfo() {
    final rnd = Random();
    dropInfo.clear();
    for (int i = 0; i < 6; i++) {
      dropInfo.add([]);
      for (int j = 0; j < 5; j++) {
        int dropIndex = rnd.nextInt(6);
        dropInfo[i].add(dropIndex);
      }
    }
  }
}
