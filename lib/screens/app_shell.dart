import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../state/app_session_controller.dart';
import '../widgets/ambient_backdrop.dart';
import '../widgets/app_shell_scope.dart';
import '../widgets/brand_mark.dart';
import 'alerts_screen.dart';
import 'device_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'trends_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (_index == index) {
      return;
    }
    setState(() => _index = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onOpenTrends: () => _goTo(1),
        onOpenAlerts: () => _goTo(2),
        onOpenDevice: () => _goTo(3),
      ),
      const TrendsScreen(),
      AlertsScreen(onOpenDevice: () => _goTo(3)),
      DeviceScreen(
        onOpenTrends: () => _goTo(1),
        onOpenAlerts: () => _goTo(2),
      ),
      SettingsScreen(
        onSignOut: context.read<AppSessionController>().signOut,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AmbientBackdrop(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useRail = constraints.maxWidth >= 980;

            return Row(
              children: [
                if (useRail) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 0, 18),
                    child: _AdaptiveRail(
                      currentIndex: _index,
                      onSelect: _goTo,
                    ),
                  ),
                  const SizedBox(width: 18),
                ],
                Expanded(
                  child: AppShellScope(
                    currentIndex: _index,
                    goTo: _goTo,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (value) => setState(() => _index = value),
                      children: pages,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = MediaQuery.of(context).size.width >= 980;
          if (useRail) {
            return const SizedBox.shrink();
          }

          return _NeoBottomBar(
            currentIndex: _index,
            onTap: _goTo,
          );
        },
      ),
    );
  }
}

class _NeoBottomBar extends StatelessWidget {
  const _NeoBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem('Dashboard', Icons.home_outlined, Icons.home_rounded),
      _NavItem('Trends', Icons.show_chart_outlined, Icons.show_chart_rounded),
      _NavItem(
        'Alerts',
        Icons.notifications_none_rounded,
        Icons.notifications_rounded,
      ),
      _NavItem(
        'Device',
        Icons.bluetooth_searching_rounded,
        Icons.bluetooth_connected_rounded,
      ),
      _NavItem(
        'Settings',
        Icons.settings_outlined,
        Icons.settings_rounded,
      ),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.panelGradient,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.softShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('nav-${item.label.toLowerCase()}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppTheme.secondarySoft,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: selected ? Border.all(color: AppTheme.border) : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.secondary.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              color: selected ? AppTheme.primaryDeep : AppTheme.textSecondary,
              size: 18,
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    color: selected
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdaptiveRail extends StatelessWidget {
  const _AdaptiveRail({
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const items = [
      _SidebarItem(index: 0, label: 'Dashboard', icon: Icons.home_rounded),
      _SidebarItem(index: 1, label: 'Trends', icon: Icons.show_chart_rounded),
      _SidebarItem(
          index: 2, label: 'Alerts', icon: Icons.notifications_rounded),
      _SidebarItem(index: 3, label: 'Device', icon: Icons.bluetooth_connected),
      _SidebarItem(index: 4, label: 'Profile', icon: Icons.person_rounded),
    ];

    return Container(
      width: 232,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: _RailBrand(),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Adaptive infant wellness',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 20),
          for (final item in items) ...[
            _SidebarButton(
              label: item.label,
              icon: item.icon,
              selected: currentIndex == item.index,
              onTap: () => onSelect(item.index),
            ),
            const SizedBox(height: 6),
          ],
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSoft,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              'A calmer layout appears on larger screens so key monitoring states stay easy to scan.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppTheme.secondarySoft,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: AppTheme.border) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppTheme.primaryDeep : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem {
  const _SidebarItem({
    required this.index,
    required this.label,
    required this.icon,
  });

  final int index;
  final String label;
  final IconData icon;
}

class _RailBrand extends StatelessWidget {
  const _RailBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const FittedBox(
            fit: BoxFit.contain,
            child: BrandSymbol(compact: true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'NeoLife AI',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryDeep,
                ),
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
