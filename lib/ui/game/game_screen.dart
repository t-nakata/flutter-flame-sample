import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame/constants.dart';
import 'package:flutter_flame/puzzle_game.dart';
import 'package:flutter_flame/ui/game/drop_field.dart';

class GameScreen extends PositionComponent with HasGameRef<PuzzleGame> {
  final ScreenCallback screenCallback;
  late TextComponent titleTextComponent;
  late HudButtonComponent button;
  int col = 8;
  int row = 7;

  late DropField dropField;
  double dropSize = 10;

  GameScreen(this.screenCallback) {
    anchor = Anchor.topLeft;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    titleTextComponent = TextComponent(
      text: "ゲーム画面",
      textRenderer: Paints.large,
    )
      ..anchor = Anchor.center
      ..position = Vector2(gameRef.size.x / 2, gameRef.size.y / 10);

    // button
    // Fixme: 座標がおかしいので修正する必要がある
    button = HudButtonComponent(
      margin: const EdgeInsets.all(8),
      button: TextComponent(text: "←",
          textRenderer: Paints.normal,
          position: Vector2(10, 20),
          size: Vector2(80, 80),
      ),
      onPressed: () {
        screenCallback.call(Screen.title, "");
      }
    );

    dropField = DropField(dropSize, gameRef, col, row);
    await dropField.init();

    add(titleTextComponent);
    add(button);
    add(dropField);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    dropSize = size.x / col;
  }
}
