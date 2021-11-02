import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame/constants.dart';
import 'package:flutter_flame/puzzle_game.dart';

class TitleScreen extends PositionComponent {
  final ScreenCallback screenCallback;
  late TextComponent titleTextComponent;
  late StartButton buttonComponent;

  TitleScreen(
    this.screenCallback,
  ) {
    titleTextComponent = TextComponent(
      "パズルゲーム",
      textRenderer: Paints.large,
    )..anchor = Anchor.topCenter;

    buttonComponent = StartButton(screenCallback, position: Vector2(0, 500.0))
      ..anchor = Anchor.center;
    add(titleTextComponent);
    add(buttonComponent);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    print("onGameResize: gameSize: $gameSize");
    titleTextComponent.x = gameSize.x / 2;
    titleTextComponent.y = gameSize.y / 10;
    buttonComponent.x = gameSize.x / 2;
    buttonComponent.y = gameSize.y / 10 * 8;
  }
}

class StartButton extends PositionComponent with Tappable {
  late TextComponent textComponent;
  bool _beenPressed = false;
  ScreenCallback screenCallback;

  StartButton(this.screenCallback, {Vector2? position})
      : super(position: position ?? Vector2(0, 0), size: Vector2(280, 68)) {

    textComponent = TextComponent("Game Start", textRenderer: Paints.large)
      ..anchor = Anchor.center
      ..x = (size.x - 10) / 2
      ..y = size.y / 2;
    add(textComponent);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _beenPressed ? Paints.grey : Paints.white);
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (_beenPressed) {
      screenCallback.call(Screen.game);
    }
    _beenPressed = false;
    return true;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    _beenPressed = true;
    return true;
  }

  @override
  bool onTapCancel() {
    _beenPressed = false;
    return true;
  }
}
