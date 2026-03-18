# NeoLife AI Flutter Prototype

NeoLife AI is a frontend-only Flutter prototype for an infant wellness monitoring startup concept. The app uses local mock sensor data and a clean architecture so the mock service can be replaced later with a BLE-based ESP32 integration.

## Features

- Dashboard with simulated connect and disconnect flow
- Live mock sensor cards refreshed every second
- Placement-aware mode switching for ankle and chest placement
- Health status classification with alert explanation
- Signal quality indicator
- Compact alert history
- Trend graphs built with `fl_chart`

## Project Structure

```text
lib/
  app.dart
  main.dart
  core/
    theme/
      app_theme.dart
  models/
    alert_event.dart
    placement_mode.dart
    sensor_reading.dart
    sensor_status.dart
  screens/
    app_shell.dart
    home_screen.dart
    trends_screen.dart
  services/
    mock_sensor_service.dart
    sensor_service.dart
  state/
    neo_life_controller.dart
  widgets/
    alert_history_card.dart
    connection_card.dart
    quality_indicator_card.dart
    section_header.dart
    sensor_metric_card.dart
    status_summary_card.dart
    trend_chart_card.dart
test/
  widget_test.dart
```

## Setup

1. Install Flutter on your machine and confirm `flutter --version` works.
2. Create a new app folder or use this folder as the project root.
3. Run `flutter pub get`.
4. Start the app on Chrome or Android.

## Exact Commands

```bash
flutter create neo_life_ai
cd neo_life_ai
flutter pub add provider:^6.1.5+1
flutter pub add fl_chart:^1.1.1
```

Then replace the generated `lib/`, `test/`, and `pubspec.yaml` with the files in this project and run:

```bash
flutter pub get
flutter run -d chrome
```

For Android:

```bash
flutter devices
flutter run -d <device-id>
```
