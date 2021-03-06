import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame/ui/game/game_screen.dart';
import 'package:flutter_flame/ui/title/title_screen.dart';

typedef ScreenCallback = void Function(Screen, String);

class PuzzleGame extends FlameGame with HasTappables, HasDraggables {
  Screen _currentScreen = Screen.title;

  late TitleScreen _titleScreen;
  late GameScreen _gameScreen;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _titleScreen = TitleScreen(
      (screen, value) {
        remove(_titleScreen);
        _currentScreen = screen;
        if (screen == Screen.game) {
          if (value == "normal") {
            _gameScreen = GameScreen(
              (screen, value) => onGameScreenCallback(
                screen,
                value,
              ),
            );
            _gameScreen.col = 6;
            _gameScreen.row = 5;
          } else if (value == "8x7") {
            _gameScreen = GameScreen(
              (screen, value) => onGameScreenCallback(
                screen,
                value,
              ),
            );
            _gameScreen.col = 8;
            _gameScreen.row = 7;
          }
          add(_gameScreen);
        }
      },
    );
    _gameScreen = GameScreen(
      (screen, value) => onGameScreenCallback(
        screen,
        value,
      ),
    );
    add(_titleScreen);
    // add(_gameScreen);

    add(FpsTextComponent(position: Vector2(0, 0)));
  }


  @override
  Color backgroundColor() => const Color(0xFFe3e3e3);

  void onGameScreenCallback(Screen screen, String value) {
    print("onTapped ScreenCallback: $screen");
    remove(_gameScreen);
    _currentScreen = screen;
    // TODO 画面遷移の定義
    switch (screen) {
      case Screen.title:
        add(_titleScreen);
        break;
    }
  }
}

enum Screen {
  title,
  game,
}
