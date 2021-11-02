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
  int? _dragId;
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
        sprite: dropSprite)
      ..anchor = Anchor.center;
  }

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    print("onDragStart: ${info.raw}, pointerId: $pointerId");
    if (_dragId != null) {
      return false;
    } else {
      _dragId = pointerId;
    }

    var localPosition = info.eventPosition.game - position;
    _dragDeltaPosition = localPosition;

    _draggedDrop = isHitDrop(localPosition);

    final drop = _draggedDrop;
    if (drop is SpriteComponent) {
      drop.setOpacity(0.0);
      _overlayDrop = createOverlayDrop(drop, localPosition);
      add(_overlayDrop!);
      return true;
    }

    return false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    // print("onDragUpdate: ${info.raw}, overlayDrop: ${_overlayDrop?.position}");
    if (_dragId != pointerId) {
      return false;
    }

    final overlayDrop = _overlayDrop;
    if (overlayDrop is SpriteComponent) {
      final localPosition = info.eventPosition.game - position;
      // print("width: $width, height: $height, local: $localPosition");
      if (!isFieldIn(localPosition)) {
        // フィールド外なので後続処理しない
        return false;
      }

      overlayDrop.position.setFrom(localPosition);

      // 入れ替え判定
      swapDrop(isHitDrop(localPosition), _draggedDrop);
    }

    return super.onDragUpdate(pointerId, info);
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    print("onDragEnd: ${info.raw}");
    if (_dragId != pointerId) {
      return false;
    }

    endDrag();
    return super.onDragEnd(pointerId, info);
  }

  @override
  bool onDragCancel(int pointerId) {
    print("onDragCancel: ${pointerId}");
    if (_dragId != pointerId) {
      return false;
    }
    endDrag();
    return super.onDragCancel(pointerId);
  }

  void endDrag() {
    _draggedDrop?.setOpacity(1.0);
    if (_overlayDrop != null) {
      remove(_overlayDrop!);
    }
    _draggedDrop = null;
    _dragId = null;
  }

  SpriteComponent? isHitDrop(Vector2 hitPosition) {
    for (var element in children) {
      if (element is SpriteComponent) {
        if (element.position.x <= hitPosition.x &&
            element.position.x + element.size.x > hitPosition.x &&
            element.position.y <= hitPosition.y &&
            element.position.y + element.size.y > hitPosition.y) {
          return element;
        }
      }
    }

    return null;
  }

  bool isFieldIn(Vector2 vector) {
    return !(0 > vector.x ||
        vector.x > width ||
        0 > vector.y ||
        vector.y > height);
  }

  void swapDrop(SpriteComponent? sc1, SpriteComponent? sc2) {
    final list = [
      dropSize * 0,
      dropSize * 1,
      dropSize * 2,
      dropSize * 3,
      dropSize * 4,
      dropSize * 5,
      dropSize * 6,
    ];

    if (sc1 != null && sc2 != null) {
      // Swap
      // print("before: ${targetDrop.position}, ${draggedDrop.position}");
      final swapV = sc1.position.clone();
      if (list.contains(swapV.x) && list.contains(swapV.y)) {
        sc1.position.setFrom(sc2.position);
        sc2.position.setFrom(swapV);
      } else {
        print("out: $swapV, list: $list");
      }

      // print("after : ${targetDrop.position}, ${draggedDrop.position}");
    }
  }
}
