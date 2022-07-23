import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame/constants.dart';
import 'package:flutter_flame/puzzle_game.dart';

class TitleScreen extends PositionComponent with HasGameRef<PuzzleGame>  {
  final ScreenCallback screenCallback;
  late TextComponent titleTextComponent;
  late StartButton buttonComponent;
  late StartButton buttonComponent2;

  TitleScreen(
    this.screenCallback,
  ) {}

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    titleTextComponent = TextComponent(
      text: "パズルゲーム",
      textRenderer: Paints.large,
    )
      ..anchor = Anchor.center
      ..position = Vector2(gameRef.size.x / 2, gameRef.size.y / 10);

    buttonComponent =
        StartButton(screenCallback, "normal", position: Vector2(0, 500.0))
          ..anchor = Anchor.center
          ..position = Vector2(gameRef.size.x / 2, 500);
    buttonComponent2 =
        StartButton(screenCallback, "8x7", position: Vector2(0, 600.0))
          ..anchor = Anchor.center
          ..position = Vector2(gameRef.size.x / 2, 600);

    add(titleTextComponent);
    add(buttonComponent);
    add(buttonComponent2);
  }

}

class StartButton extends PositionComponent with Tappable {
  late TextComponent textComponent;
  bool _beenPressed = false;
  ScreenCallback screenCallback;
  String value;

  StartButton(this.screenCallback, this.value, {Vector2? position})
      : super(position: position ?? Vector2(0, 0), size: Vector2(280, 68)) {
    textComponent = TextComponent(text: "Start $value", textRenderer: Paints.large)
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
      screenCallback.call(Screen.game, value);
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
