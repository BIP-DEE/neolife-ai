class SensorReading {
  const SensorReading({
    required this.timestamp,
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.motionLevel,
    required this.breathingRate,
    required this.signalQuality,
  });

  final DateTime timestamp;
  final int heartRate;
  final int spo2;
  final double temperature;
  final double motionLevel;
  final double breathingRate;
  final double signalQuality;
}
