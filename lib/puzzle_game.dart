import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter_flame/ui/game/game_screen.dart';
import 'package:flutter_flame/ui/title/title_screen.dart';

typedef ScreenCallback = void Function(Screen);

class PuzzleGame extends FlameGame
    with FPSCounter, HasTappableComponents, HasDraggableComponents {
  Screen _currentScreen = Screen.title;

  late TitleScreen _titleScreen;
  late GameScreen _gameScreen;

  static final fpsTextPaint = TextPaint(
    config: const TextPaintConfig(
      color: Color(0xFFFFFFFF),
    ),
  );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    _titleScreen = TitleScreen(
      (screen) {
        remove(_titleScreen);
        _currentScreen = screen;
        if (screen == Screen.game) {
          add(_gameScreen);
        }
      },
    );
    _gameScreen = GameScreen(
      (screen) {
        remove(_titleScreen);
        _currentScreen = screen;
        // TODO 画面遷移の定義
      },
    );
    // add(_titleScreen);
    add(_gameScreen);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (_currentScreen) {
      case Screen.title:
        _titleScreen.render(canvas);
        break;
      case Screen.game:
        _gameScreen.render(canvas);
        break;
    }

    fpsTextPaint.render(canvas, fps(120).toString(), Vector2(0, 50));
  }

  @override
  Color backgroundColor() => const Color(0xFFe3e3e3);
}

enum Screen {
  title,
  game,
}
