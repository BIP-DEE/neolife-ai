enum PlacementMode { ankle, chest }

extension PlacementModeX on PlacementMode {
  String get label {
    switch (this) {
      case PlacementMode.ankle:
        return 'Ankle Mode';
      case PlacementMode.chest:
        return 'Chest Mode';
    }
  }

  String get shortLabel {
    switch (this) {
      case PlacementMode.ankle:
        return 'Ankle';
      case PlacementMode.chest:
        return 'Chest';
    }
  }

  String get helperText {
    switch (this) {
      case PlacementMode.ankle:
        return 'Focus on temperature trend and limb motion.';
      case PlacementMode.chest:
        return 'Focus on temperature trend and breathing effort.';
    }
  }
}
