import 'dart:collection';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter_flame/constants.dart';
import 'package:flutter_flame/puzzle_game.dart';
import 'package:flutter_flame/ui/game/drop_data.dart';
import 'package:flutter_flame/ui/game/game_data.dart';

typedef SpriteComponentCallBack = void Function(SpriteComponent);

class DropManager {
  HashMap<String, DropData> dropMap = HashMap<String, DropData>();
  double dropSize;
  PuzzleGame game;
  bool availableUserAction = true;
  SpriteComponentCallBack removeCallBack;
  SpriteComponentCallBack addCallBack;
  final int col;
  final int row;
  int dropDownEffectCount = 0;
  GameData data = GameData();

  DropManager(this.dropSize, this.game, this.col, this.row,
      {required this.addCallBack, required this.removeCallBack});

  init() {
    createDropList();
    printDropMap();
  }

  createDropList() {
    final rnd = Random();
    dropMap.clear();
    for (int i = 0; i < col; i++) {
      for (int j = 0; j < row; j++) {
        int dropType = rnd.nextInt(6);
        String key = "${i}_$j";
        dropMap[key] = DropData(dropSize, dropType, i, j);
      }
    }
  }

  addNewDrop(int x, int y) {
    final rnd = Random();
    int dropType = rnd.nextInt(6);
    String key = "${x}_$y";
    dropMap[key] = DropData(dropSize, dropType, x, y);
  }

  Future<SpriteComponent> createDrop(int x, int y) async {
    final data = dropMap["${x}_$y"];
    final dropType = data!.dropType;
    final dropSprite = await game.loadSprite(ImagePath.getPath(dropType));
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
    data.component = drop;
    return drop;
  }

  onDragStart() {}

  swap(Vector2 v1, Vector2 v2) {
    if (v1.distanceTo(v2) == 0) {
      return;
    }
    final drop1 = dropMap.values.firstWhere((data) => data.position == v1);
    final drop2 = dropMap.values.firstWhere((data) => data.position == v2);

    final swapV = drop1.position.clone();
    drop1.move(drop2.position);
    drop2.move(swapV);

    dropMap[drop1.getKey()] = drop1;
    dropMap[drop2.getKey()] = drop2;
    printDropMap();
  }

  onDragEnd() async {
    // Dropの3連チェック
    List<List<DropData>> removeList = checkChain();
    print("removeList: $removeList");
    fadeOutEffect(removeList.toList());
    data.addCombo(removeList.length);
  }

  void onCompleteFadeOut() {
    print("onCompleteFadeOut");
    dropDownEffect();
  }

  void onCompleteDropDown() {
    dropDownEffectCount--;
    if (dropDownEffectCount == 0) {
      print("onCompleteDropDown, $data");
      printDropMap();
      onDragEnd();
    }
  }

  List<List<DropData>> checkChain() {
    final List<List<DropData>> chains = [];

    // 縦3連以上を探す
    List<DropData> tempList = [];
    int currentDropType = -1;
    for (int i = 0; i < col; i++) {
      for (int j = 0; j < row; j++) {
        var data = dropMap["${i}_$j"];
        if (data == null) {
          continue;
        }

        if (currentDropType == data.dropType) {
          tempList.add(data);
        } else {
          if (tempList.length >= 3) {
            chains.add(tempList.toList());
          }
          tempList.clear();
          tempList.add(data);
          currentDropType = data.dropType;
        }
      }
      if (tempList.length >= 3) {
        chains.add(tempList.toList());
      }
      tempList.clear();
      currentDropType = -1;
    }

    // 横3連以上を探す
    for (int j = 0; j < row; j++) {
      for (int i = 0; i < col; i++) {
        var data = dropMap["${i}_$j"];
        if (data == null) {
          continue;
        }

        if (currentDropType == data.dropType) {
          tempList.add(data);
        } else {
          if (tempList.length >= 3) {
            chains.add(tempList.toList());
          }
          tempList.clear();
          tempList.add(data);
          currentDropType = data.dropType;
        }
      }
      if (tempList.length >= 3) {
        chains.add(tempList.toList());
      }
      tempList.clear();
      currentDropType = -1;
    }

    // 縦横連結チェック
    final c = chains.toList();
    var loop = true;
    do {
      loop = false;
      for (var drops in c) {
        for (var drop in drops) {
          var newChains =
              chains.where((chain) => chain.contains(drop)).toList();
          if (newChains.length >= 2) {
            // 同じDropを含むListが複数あるので連結する
            loop = true;
            List<DropData> newDrops = [];
            for (var chain in newChains) {
              chains.remove(chain);
              newDrops.addAll(chain);
            }
            chains.add(newDrops);
            break;
          }
        }
      }
    } while (loop);

    return chains;
  }

  void fadeOutEffect(List<List<DropData>> hideList) {
    if (hideList.isNotEmpty) {
      // drop消すモード
      availableUserAction = false;
      // まず非表示
      var count = 0;
      bool listenerAdded = false;
      while (hideList.isNotEmpty) {
        count++;
        var target = hideList.first;
        hideList.remove(target);
        data.remove(target.first.dropType, target.length);
        for (var drop in target) {
          var fadeOut = OpacityEffect.to(
            0,
            EffectController(
              duration: 0.2,
              startDelay: 0.3 * count,
            ),
          );
          drop.component.add(fadeOut);
          drop.setVisible(false);
          if (hideList.isEmpty && !listenerAdded) {
            listenerAdded = true;
            fadeOut.onComplete = () => onCompleteFadeOut();
          }
        }
      }
    } else {
      availableUserAction = true;
      data.resetCombo();
    }
  }

  void dropDownEffect() async {
    final visibleList =
        dropMap.values.where((drop) => drop.isVisible()).toList();
    final removeList =
        dropMap.values.where((drop) => !drop.isVisible()).toList();

    // 削除
    for (var drop in removeList) {
      removeCallBack.call(drop.component);
    }

    for (int i = 0; i < col; i++) {
      var drops = visibleList.where((d) => d.x == i).toList();
      drops.sort((a, b) => a.y.compareTo(b.y) * -1);
      for (int j = 0; j < row; j++) {
        var newY = row - 1 - j;
        if (drops.length > j) {
          var drop = drops[j];
          var oldY = drop.y;
          dropDownEffectCount++;
          drop.component.add(
            MoveToEffect(
              Vector2(0, dropSize * (oldY - newY)),
              EffectController(duration: 1.0),
              onComplete: () {
                drop.y = newY;
                drop.move(Vector2(dropSize * i, dropSize * newY));
                dropMap[drop.getKey()] = drop;
                onCompleteDropDown();
              },
            ),
          );
        } else {
          var oldY = drops.length - j - 1;
          addNewDrop(i, oldY);
          var drop = dropMap["${i}_$oldY"];
          if (drop != null) {
            drop.component = await createDrop(i, oldY);
            addCallBack.call(drop.component);
            dropDownEffectCount++;
            drop.component.add(
              MoveToEffect(
                Vector2(0, dropSize * (oldY - newY)),
                EffectController(duration: 1.0),
                onComplete: () {
                  dropMap.remove("${i}_$oldY");
                  drop.y = newY;
                  drop.move(Vector2(dropSize * i, dropSize * newY));
                  dropMap[drop.getKey()] = drop;
                  onCompleteDropDown();
                },
              ),
            );
          }
        }
      }
    }
  }

  printDropMap() {
    String message = "{\n";
    for (int j = 0; j < row; j++) {
      for (int i = 0; i < col; i++) {
        String key = "${i}_$j";
        int type = dropMap[key]?.dropType ?? 0;
        message += "$type ";
      }
      message += "\n";
    }
    message += "}";
    print(message);
  }
}
