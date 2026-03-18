import 'dart:async';
import 'dart:math';

import '../models/placement_mode.dart';
import '../models/sensor_reading.dart';
import 'sensor_service.dart';

class MockSensorService implements SensorService {
  MockSensorService();

  final StreamController<SensorReading> _controller =
      StreamController<SensorReading>.broadcast();
  final Random _random = Random();

  Timer? _timer;
  bool _isConnected = false;
  PlacementMode _placementMode = PlacementMode.ankle;
  int _tick = 0;

  @override
  Stream<SensorReading> get readings => _controller.stream;

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> connect() async {
    if (_isConnected) {
      return;
    }

    _isConnected = true;

    // Future BLE note:
    // Replace the timer with a Bluetooth characteristic subscription and
    // convert incoming bytes into SensorReading objects here.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _controller.add(_generateReading());
    });
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void updatePlacementMode(PlacementMode mode) {
    _placementMode = mode;
  }

  SensorReading _generateReading() {
    _tick += 1;
    final wave = sin(_tick / 3.0);
    final secondaryWave = cos(_tick / 5.0);
    final noise = (_random.nextDouble() - 0.5);

    final heartRate = _clampInt(
      (_placementMode == PlacementMode.chest ? 136 : 131) +
          (wave * 6).round() +
          (_tick % 14 == 0 ? 12 : 0) +
          (noise * 5).round(),
      112,
      172,
    );

    final spo2 = _clampInt(
      98 + (secondaryWave * 1.8).round() - (_tick % 18 == 0 ? 3 : 0),
      91,
      100,
    );

    final temperature = _clampDouble(
      (_placementMode == PlacementMode.chest ? 37.1 : 36.7) +
          (wave * 0.20) +
          (_tick % 16 == 0 ? 0.55 : 0) +
          (noise * 0.08),
      36.2,
      38.6,
    );

    final motionLevel = _clampDouble(
      34 + (secondaryWave * 12) + (_tick % 12 == 0 ? 28 : 0) + (noise * 8),
      8,
      95,
    );

    final breathingRate = _clampDouble(
      32 + (wave * 3.8) + (_tick % 15 == 0 ? 10 : 0) + (noise * 2.8),
      22,
      58,
    );

    final signalQuality = _clampDouble(
      0.86 + (secondaryWave * 0.08) - (_tick % 13 == 0 ? 0.18 : 0),
      0.45,
      0.99,
    );

    return SensorReading(
      timestamp: DateTime.now(),
      heartRate: heartRate,
      spo2: spo2,
      temperature: temperature,
      motionLevel: motionLevel,
      breathingRate: breathingRate,
      signalQuality: signalQuality,
    );
  }

  int _clampInt(int value, int min, int max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  double _clampDouble(double value, double min, double max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
