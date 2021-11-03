import 'package:flame/components.dart';
import 'package:flutter_flame/constants.dart';

class DropData {
  final double dropSize;
  int dropType;
  int x = 0;
  int y = 0;
  Vector2 position = Vector2(0, 0);
  bool _isVisible = true;
  SpriteComponent? component;

  DropData(this.dropSize, this.dropType, this.x, this.y) {
    position = Vector2(x * dropSize, y * dropSize);
  }

  void move(Vector2 newPosition) {
    position.setFrom(newPosition);

    x = (newPosition.x / dropSize).round();
    y = (newPosition.y / dropSize).round();
  }

  void setVisible(bool visible) {
    _isVisible = visible;
  }

  bool isVisible() => _isVisible;

  String getKey() => "${x}_$y";


  @override
  String toString() {
    return "$x,$y,$dropType";
  }
}
