import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/alert_event.dart';
import '../models/placement_mode.dart';
import '../models/sensor_reading.dart';
import '../models/sensor_status.dart';
import '../services/mock_sensor_service.dart';
import '../services/sensor_service.dart';

class NeoLifeController extends ChangeNotifier {
  NeoLifeController({SensorService? sensorService})
      : _sensorService = sensorService ?? MockSensorService() {
    _sensorService.updatePlacementMode(_placementMode);
    _readingSubscription = _sensorService.readings.listen(_handleReading);
    _seedAlertHistory();
  }

  final SensorService _sensorService;
  late final StreamSubscription<SensorReading> _readingSubscription;

  PlacementMode _placementMode = PlacementMode.ankle;
  SensorReading? _latestReading;
  SensorStatus _status = SensorStatus.stable;
  String _alertExplanation =
      'Signals are calm and consistent. NeoLife AI is ready to monitor.';
  final List<SensorReading> _history = <SensorReading>[];
  final List<AlertEvent> _alertHistory = <AlertEvent>[];
  String? _lastAlertSignature;
  SensorStatus? _pendingStatus;
  String? _pendingExplanation;
  int _pendingStatusCount = 0;

  PlacementMode get placementMode => _placementMode;
  SensorReading? get latestReading => _latestReading;
  SensorStatus get status => _status;
  String get alertExplanation => _alertExplanation;
  bool get isConnected => _sensorService.isConnected;
  List<SensorReading> get history => List.unmodifiable(_history);
  List<AlertEvent> get alertHistory => List.unmodifiable(_alertHistory);

  String get placementMetricTitle {
    return _placementMode == PlacementMode.ankle
        ? 'Motion Trend'
        : 'Breathing Trend';
  }

  String get placementMetricUnit {
    return _placementMode == PlacementMode.ankle ? '%' : 'rpm';
  }

  double get placementMetricValue {
    final reading = _latestReading;
    if (reading == null) {
      return 0;
    }
    return _placementMode == PlacementMode.ankle
        ? reading.motionLevel
        : reading.breathingRate;
  }

  String get temperatureTitle {
    return _placementMode == PlacementMode.ankle
        ? 'Peripheral Temp'
        : 'Core Temp';
  }

  double get signalQuality => _latestReading?.signalQuality ?? 0.84;

  String get qualityLabel {
    final value = signalQuality;
    if (value >= 0.85) {
      return 'High confidence';
    }
    if (value >= 0.65) {
      return 'Good confidence';
    }
    return 'Review sensor contact';
  }

  String get connectionLabel => isConnected ? 'Connected' : 'Disconnected';

  Future<void> toggleConnection() async {
    if (isConnected) {
      await _sensorService.disconnect();
      _alertExplanation =
          'Sensor stream paused. Reconnect to resume live infant monitoring.';
    } else {
      await _sensorService.connect();
      _alertExplanation =
          'Mock sensor connected. Live wellness values are streaming locally.';
    }
    notifyListeners();
  }

  void setPlacementMode(PlacementMode mode) {
    if (_placementMode == mode) {
      return;
    }

    _placementMode = mode;
    _sensorService.updatePlacementMode(mode);
    _recomputeStatus();
    notifyListeners();
  }

  String trendLabel(double Function(SensorReading reading) selector) {
    if (_history.length < 6) {
      return 'Building baseline';
    }

    final readings = _history;
    final splitIndex = readings.length - 3;
    final previous = readings.sublist(max(0, splitIndex - 3), splitIndex);
    final recent = readings.sublist(splitIndex);

    final previousAverage =
        previous.map(selector).reduce((a, b) => a + b) / previous.length;
    final recentAverage =
        recent.map(selector).reduce((a, b) => a + b) / recent.length;
    final difference = recentAverage - previousAverage;

    if (difference > 1.2) {
      return 'Rising';
    }
    if (difference < -1.2) {
      return 'Falling';
    }
    return 'Steady';
  }

  String get heartRateTrend =>
      trendLabel((reading) => reading.heartRate.toDouble());
  String get spo2Trend => trendLabel((reading) => reading.spo2.toDouble());
  String get temperatureTrend => trendLabel((reading) => reading.temperature);
  String get placementTrend => trendLabel(
        (reading) => _placementMode == PlacementMode.ankle
            ? reading.motionLevel
            : reading.breathingRate,
      );

  void _handleReading(SensorReading reading) {
    _latestReading = reading;
    _history.add(reading);
    if (_history.length > 30) {
      _history.removeAt(0);
    }
    _recomputeStatus();
    notifyListeners();
  }

  void _recomputeStatus() {
    if (_latestReading == null) {
      _status = SensorStatus.stable;
      _pendingStatus = null;
      _pendingExplanation = null;
      _pendingStatusCount = 0;
      return;
    }

    final reading = _latestReading!;
    final issues = <String>[];
    var computedStatus = SensorStatus.stable;

    if (reading.temperature >= 38.2) {
      computedStatus = _maxStatus(computedStatus, SensorStatus.anomaly);
      issues.add('high temperature');
    } else if (reading.temperature >= 37.6 || temperatureTrend == 'Rising') {
      computedStatus = _maxStatus(computedStatus, SensorStatus.unusual);
      issues.add('rising temperature trend');
    }

    if (reading.heartRate >= 165) {
      computedStatus = _maxStatus(computedStatus, SensorStatus.anomaly);
      issues.add('elevated heart rate');
    } else if (reading.heartRate >= 148 || heartRateTrend == 'Rising') {
      computedStatus = _maxStatus(computedStatus, SensorStatus.unusual);
      issues.add('elevated HR trend');
    }

    if (reading.spo2 <= 92) {
      computedStatus = _maxStatus(computedStatus, SensorStatus.anomaly);
      issues.add('low oxygen saturation');
    } else if (reading.spo2 <= 95 || spo2Trend == 'Falling') {
      computedStatus = _maxStatus(computedStatus, SensorStatus.unusual);
      issues.add('softening SpO2 trend');
    }

    if (_placementMode == PlacementMode.ankle) {
      if (reading.motionLevel >= 82) {
        computedStatus = _maxStatus(computedStatus, SensorStatus.anomaly);
        issues.add('persistent motion spike');
      } else if (reading.motionLevel >= 64) {
        computedStatus = _maxStatus(computedStatus, SensorStatus.unusual);
        issues.add('higher movement pattern');
      }
    } else {
      if (reading.breathingRate >= 50) {
        computedStatus = _maxStatus(computedStatus, SensorStatus.anomaly);
        issues.add('rapid breathing pattern');
      } else if (reading.breathingRate >= 44) {
        computedStatus = _maxStatus(computedStatus, SensorStatus.unusual);
        issues.add('breathing trend rising');
      }
    }

    if (_hasSustainedConcern()) {
      computedStatus = _maxStatus(computedStatus, SensorStatus.anomaly);
      if (!issues.contains('multi-signal change sustained')) {
        issues.add('multi-signal change sustained');
      }
    }

    final computedExplanation = issues.isEmpty
        ? (isConnected
            ? 'Signals are stable and within the expected range.'
            : _alertExplanation)
        : _buildExplanation(issues);

    _applyStatusSmoothing(
      computedStatus: computedStatus,
      computedExplanation: computedExplanation,
    );
  }

  void _applyStatusSmoothing({
    required SensorStatus computedStatus,
    required String computedExplanation,
  }) {
    if (computedStatus == _status) {
      _pendingStatus = null;
      _pendingExplanation = null;
      _pendingStatusCount = 0;
      _alertExplanation = computedExplanation;
      return;
    }

    if (_pendingStatus == computedStatus) {
      _pendingStatusCount += 1;
      _pendingExplanation = computedExplanation;
    } else {
      _pendingStatus = computedStatus;
      _pendingExplanation = computedExplanation;
      _pendingStatusCount = 1;
    }

    final threshold = computedStatus.priority > _status.priority ? 2 : 3;
    if (_pendingStatusCount < threshold) {
      return;
    }

    _status = computedStatus;
    _alertExplanation = _pendingExplanation ?? computedExplanation;
    _pendingStatus = null;
    _pendingExplanation = null;
    _pendingStatusCount = 0;
    _pushAlertIfNeeded(_alertExplanation, computedStatus);
  }

  bool _hasSustainedConcern() {
    if (_history.length < 4) {
      return false;
    }

    final recent = _history.sublist(_history.length - 4);
    var elevatedCount = 0;
    for (final reading in recent) {
      final heartRateFlag = reading.heartRate >= 148;
      final tempFlag = reading.temperature >= 37.6;
      final spo2Flag = reading.spo2 <= 95;
      final placementFlag = _placementMode == PlacementMode.ankle
          ? reading.motionLevel >= 64
          : reading.breathingRate >= 44;
      if (heartRateFlag || tempFlag || spo2Flag || placementFlag) {
        elevatedCount += 1;
      }
    }

    return elevatedCount >= 3;
  }

  String _buildExplanation(List<String> issues) {
    final uniqueIssues = issues.toSet().toList();
    if (uniqueIssues.length == 1) {
      return _capitalize(uniqueIssues.first);
    }
    if (uniqueIssues.length == 2) {
      return '${_capitalize(uniqueIssues[0])} + ${uniqueIssues[1]}';
    }
    return '${_capitalize(uniqueIssues[0])} + ${uniqueIssues[1]} + ${uniqueIssues[2]}';
  }

  void _pushAlertIfNeeded(String explanation, SensorStatus status) {
    final signature = '${status.name}:$explanation';
    if (_lastAlertSignature == signature) {
      return;
    }

    _lastAlertSignature = signature;
    _alertHistory.insert(
      0,
      AlertEvent(
        title: status.label,
        details: explanation,
        timestamp: DateTime.now(),
        status: status,
      ),
    );

    if (_alertHistory.length > 6) {
      _alertHistory.removeLast();
    }
  }

  void _seedAlertHistory() {
    final now = DateTime.now();
    _alertHistory.addAll(
      <AlertEvent>[
        AlertEvent(
          title: 'Stable Window',
          details: 'Baseline captured after repositioning on ankle placement.',
          timestamp: now.subtract(const Duration(minutes: 18)),
          status: SensorStatus.stable,
        ),
        AlertEvent(
          title: 'Unusual Trend',
          details: 'Rising temperature trend + elevated HR trend',
          timestamp: now.subtract(const Duration(minutes: 11)),
          status: SensorStatus.unusual,
        ),
        AlertEvent(
          title: 'Stable Window',
          details: 'SpO2 normalized after brief movement artifact.',
          timestamp: now.subtract(const Duration(minutes: 5)),
          status: SensorStatus.stable,
        ),
      ],
    );
  }

  SensorStatus _maxStatus(SensorStatus current, SensorStatus next) {
    return next.priority > current.priority ? next : current;
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  @override
  void dispose() {
    _readingSubscription.cancel();
    _sensorService.dispose();
    super.dispose();
  }
}
