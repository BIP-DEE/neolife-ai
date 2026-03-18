import '../models/placement_mode.dart';
import '../models/sensor_reading.dart';

abstract class SensorService {
  Stream<SensorReading> get readings;
  bool get isConnected;

  Future<void> connect();
  Future<void> disconnect();

  void updatePlacementMode(PlacementMode mode);

  // Replace this abstraction with a BLE-backed implementation later.
  // The rest of the app already depends on this interface instead of the mock.
  void dispose();
}
