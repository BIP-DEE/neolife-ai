enum SensorStatus { stable, unusual, anomaly }

extension SensorStatusX on SensorStatus {
  String get label {
    switch (this) {
      case SensorStatus.stable:
        return 'Stable';
      case SensorStatus.unusual:
        return 'Unusual Trend';
      case SensorStatus.anomaly:
        return 'Sustained Anomaly';
    }
  }

  int get priority {
    switch (this) {
      case SensorStatus.stable:
        return 0;
      case SensorStatus.unusual:
        return 1;
      case SensorStatus.anomaly:
        return 2;
    }
  }
}
