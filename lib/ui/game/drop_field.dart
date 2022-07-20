import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter_flame/constants.dart';
import 'package:flutter_flame/puzzle_game.dart';
import 'package:flutter_flame/ui/game/drop_manager.dart';

class DropField extends PositionComponent with Draggable {
  final double dropSize;
  final PuzzleGame game;
  final int col;
  final int row;
  late final DropManager dropManager;

  SpriteComponent? _draggedDrop;
  SpriteComponent? _overlayDrop;
  Timer _dragTimer = Timer(15);


  DropField(this.dropSize, this.game, this.col, this.row) {
    dropManager = DropManager(
      dropSize,
      game,
      col,
      row,
      addCallBack: (drop) => add(drop),
      removeCallBack: (drop) => remove(drop),
    );
    width = dropSize * col;
    height = dropSize * row;
    position = Vector2(0, game.size.y - height - dropSize / 2);
    size = Vector2(dropSize * col, dropSize * row);
  }

  Future<void> init() async {
    dropManager.init();
    for (int i = 0; i < col; i++) {
      for (int j = 0; j < row; j++) {
        add(await dropManager.createDrop(i, j));
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), Paints.black);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _dragTimer.update(dt);
    if (_dragTimer.finished) {
      endDrag();
      print("_dragTime.finishd");
    } else {
      print("_dratTime: ${_dragTimer.progress}, ${_dragTimer.current}");
    }
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
  bool onDragStart(DragStartInfo info) {
    print("onDragStart: ${info.raw}");
    if (!dropManager.availableUserAction) {
      return false;
    }

    var localPosition = info.eventPosition.game - position;

    _draggedDrop = isHitDrop(localPosition);

    final drop = _draggedDrop;
    if (drop is SpriteComponent) {
      drop.setOpacity(0.0);
      _overlayDrop = createOverlayDrop(drop, localPosition);
      add(_overlayDrop!);
      _dragTimer = Timer(10);
      _dragTimer.start();
      return true;
    }

    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    // print("onDragUpdate: ${info.raw}, overlayDrop: ${_overlayDrop?.position}");

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

    return super.onDragUpdate(info);
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    print("onDragEnd: ${info.raw}");

    endDrag();
    return super.onDragEnd(info);
  }

  @override
  bool onDragCancel() {
    print("onDragCancel");
    endDrag();
    return super.onDragCancel();
  }

  void endDrag() {
    _draggedDrop?.setOpacity(1.0);
    dropManager.onDragEnd();
    if (_overlayDrop != null) {
      remove(_overlayDrop!);
    }
    _draggedDrop = null;
    _dragTimer.stop();
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
      dropSize * 7,
      dropSize * 8,
      dropSize * 9,
      dropSize * 10,
    ];

    if (sc1 != null && sc2 != null) {
      // Swap
      // print("before: ${targetDrop.position}, ${draggedDrop.position}");
      final swapV = sc1.position.clone();
      if (list.contains(swapV.x) && list.contains(swapV.y)) {
        dropManager.swap(sc1.position, sc2.position);
      } else {
        print("out: $swapV, list: $list");
      }

      // print("after : ${targetDrop.position}, ${draggedDrop.position}");
    }
  }
}
