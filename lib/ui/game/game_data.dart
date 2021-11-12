class GameData {

  int totalRemove = 0;
  int redRemove = 0;
  int blueRemove = 0;
  int greenRemove = 0;
  int yellowRemove = 0;
  int purpleRemove = 0;
  int pinkRemove = 0;

  int comboCount = 0;
  int comboTotal = 0;

  init () {
    totalRemove = 0;
    redRemove = 0;
    blueRemove = 0;
    greenRemove = 0;
    yellowRemove = 0;
    purpleRemove = 0;
    pinkRemove = 0;
    comboCount = 0;
    comboTotal = 0;
  }

  remove(int type, int num) {
    switch (type) {
      case 0: // red
        removeRed(num);
        break;
      case 1: // blue
        removeBlue(num);
        break;
      case 2: // Green
        removeGreen(num);
        break;
      case 3: // Yellow
        removeYellow(num);
        break;
      case 4: // Purple
        removePurple(num);
        break;
      case 5: // Pink
        removePink(num);
        break;
    }
  }

  removeRed(int remove) {
    redRemove += remove;
    totalRemove += remove;
  }
  removeBlue(int remove) {
    blueRemove += remove;
    totalRemove += remove;
  }
  removeGreen(int remove) {
    greenRemove += remove;
    totalRemove += remove;
  }
  removeYellow(int remove) {
    yellowRemove += remove;
    totalRemove += remove;
  }
  removePurple(int remove) {
    purpleRemove += remove;
    totalRemove += remove;
  }
  removePink(int remove) {
    pinkRemove += remove;
    totalRemove += remove;
  }

  addCombo(int num) {
    comboCount += num;
    comboTotal += num;
  }

  resetCombo() {
    comboCount = 0;
  }

  @override
  String toString() {
    return "combo: $comboCount, comboTotal: $comboTotal, total: $totalRemove, red: $redRemove, blue: $blueRemove, green: $greenRemove, yellow: $yellowRemove, purple: $purpleRemove, pink: $pinkRemove";
  }
}