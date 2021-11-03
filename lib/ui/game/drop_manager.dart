import 'dart:collection';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter_flame/constants.dart';
import 'package:flutter_flame/puzzle_game.dart';
import 'package:flutter_flame/ui/game/drop_data.dart';

class DropManager {
  HashMap<String, DropData> dropMap = HashMap<String, DropData>();
  double dropSize;
  PuzzleGame game;
  bool availableUserAction = true;
  List<List<DropData>> removeList = [];

  DropManager(this.dropSize, this.game);

  init() {
    createDropList();
    printDropMap();
  }

  createDropList() {
    final rnd = Random();
    dropMap.clear();
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 5; j++) {
        int dropType = rnd.nextInt(6);
        String key = "${i}_$j";
        dropMap[key] = DropData(dropSize, dropType, i, j);
      }
    }
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
    // printDropMap();
  }

  onDragEnd() async {
    // Dropの3連チェック
    removeList = checkChain();
    print("removeList: $removeList");
    fadeOutEffect(removeList.toList());
  }

  void onCompleteFadeOut() {
    print("animation Completed");
  }

  List<List<DropData>> checkChain() {
    final List<List<DropData>> chains = [];

    // 縦3連以上を探す
    List<DropData> tempList = [];
    int currentDropType = -1;
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 5; j++) {
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
    for (int j = 0; j < 5; j++) {
      for (int i = 0; i < 6; i++) {
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
      while (hideList.isNotEmpty) {
        // OpacityEffect fadeOut = OpacityEffect(opacity: 0, duration: 0);
        count++;
        var target = hideList.first;
        hideList.remove(target);
        for (var drop in target) {
          var fadeOut = OpacityEffect(
            opacity: 0,
            duration: 0.2,
            initialDelay: 0.3 * count,
          );
          drop.component?.add(fadeOut);
          if (hideList.isNotEmpty) {
            fadeOut.onComplete = () => onCompleteFadeOut();
          }
        }
      }
    }
  }

  printDropMap() {
    String message = "{\n";
    for (int j = 0; j < 5; j++) {
      for (int i = 0; i < 6; i++) {
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