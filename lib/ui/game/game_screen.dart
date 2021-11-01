import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_flame/constants.dart';
import 'package:flutter_flame/puzzle_game.dart';

class GameScreen extends PositionComponent {
  final ScreenCallback screenCallback;
  late TextComponent titleTextComponent;

  GameScreen(this.screenCallback) {
    titleTextComponent = TextComponent(
      "ゲーム画面",
      textRenderer: Paints.large,
    )..anchor = Anchor.topCenter;
    add(titleTextComponent);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    titleTextComponent.x = gameSize.x / 2;
    titleTextComponent.y = gameSize.y / 10;
  }


}
