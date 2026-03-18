import 'sensor_status.dart';

class AlertEvent {
  const AlertEvent({
    required this.title,
    required this.details,
    required this.timestamp,
    required this.status,
  });

  final String title;
  final String details;
  final DateTime timestamp;
  final SensorStatus status;
}
