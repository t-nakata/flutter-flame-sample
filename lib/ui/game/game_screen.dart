import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/widgets.dart';
import 'package:flutter_flame/constants.dart';
import 'package:flutter_flame/puzzle_game.dart';

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
    dropField = DropField(dropSize, gameRef, dropInfo);
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

class DropField extends PositionComponent with Draggable {
  final double dropSize;
  final PuzzleGame game;
  List<List<int>> dropInfo;

  SpriteComponent? _draggedDrop;
  SpriteComponent? _overlayDrop;
  Vector2? _dragDeltaPosition;

  DropField(this.dropSize, this.game, this.dropInfo) {
    // anchor = Anchor.center;
    width = dropSize * 6;
    height = dropSize * 5;
    // position = Vector2(game.size.x / 2, game.size.y - dropSize / 2);
    position = Vector2(0, game.size.y - height - dropSize / 2);
    size = Vector2(dropSize * 6, dropSize * 5);
  }

  Future<void> init() async {
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 5; j++) {
        add(await createDrop(dropInfo[i][j], i, j));
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), Paints.black);
  }

  Future<SpriteComponent> createDrop(int imageIndex, int x, int y) async {
    final dropSprite = await game.loadSprite(ImagePath.getPath(imageIndex));
    final drop = SpriteComponent(
      position: Vector2(
        dropSize * x,
        dropSize * y,
      ),
      size: Vector2(
        dropSize,
        dropSize,
      ),
      sprite: dropSprite,
    );
    return drop;
  }

  SpriteComponent createOverlayDrop(SpriteComponent drop, Vector2 position) {
    final dropSprite = drop.sprite;
    return SpriteComponent(
      position: position,
      size: Vector2(dropSize, dropSize),
      sprite: dropSprite
    )
    ..anchor = Anchor.center;
  }

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    print("onDragStart: ${info.raw}");

    var offset = info.eventPosition.game - position;
    _dragDeltaPosition = offset;

    for (var element in children) {
      if (element is SpriteComponent) {
        if (element.position.x <= offset.x &&
            element.position.x + element.size.x > offset.x &&
            element.position.y <= offset.y &&
            element.position.y + element.size.y > offset.y) {
          _draggedDrop = element;
        }
      }
    }

    final drop = _draggedDrop;
    if (drop is SpriteComponent) {
      drop.setOpacity(0.0);
      _overlayDrop = createOverlayDrop(drop, offset);
      add(_overlayDrop!);
      return true;
    }

    return false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    // print("onDragUpdate: ${info.raw}, overlayDrop: ${_overlayDrop?.position}");

    final overlayDrop = _overlayDrop;
    final dragDeltaPosition = _dragDeltaPosition;
    if (overlayDrop is SpriteComponent && dragDeltaPosition is Vector2) {
      overlayDrop.position.setFrom(info.eventPosition.game - position);
    }




    return super.onDragUpdate(pointerId, info);
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    print("onDragEnd: ${info.raw}");
    _draggedDrop?.setOpacity(1.0);
    if (_overlayDrop != null) {
      remove(_overlayDrop!);
    }
    _draggedDrop = null;
    return super.onDragEnd(pointerId, info);
  }

  @override
  bool onDragCancel(int pointerId) {
    print("onDragCancel: ${pointerId}");
    return super.onDragCancel(pointerId);
  }
}
