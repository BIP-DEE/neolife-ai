import 'package:flutter/widgets.dart';

class AppShellScope extends InheritedWidget {
  const AppShellScope({
    super.key,
    required this.currentIndex,
    required this.goTo,
    required super.child,
  });

  final int currentIndex;
  final ValueChanged<int> goTo;

  static AppShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppShellScope>();
  }

  @override
  bool updateShouldNotify(covariant AppShellScope oldWidget) {
    return currentIndex != oldWidget.currentIndex || goTo != oldWidget.goTo;
  }
}
