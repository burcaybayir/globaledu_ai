import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/router/route_names.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/widgets/animated_bottom_nav.dart';

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.child});

  final Widget child;

  static const _navItems = [
    (
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      path: '${RouteNames.shellPath}/${RouteNames.homePath}',
    ),
    (
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      label: 'Explore',
      path: '${RouteNames.shellPath}/${RouteNames.universitiesPath}',
    ),
    (
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
      label: 'AI',
      path: '${RouteNames.shellPath}/${RouteNames.aiChatPath}',
    ),
    (
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      label: 'Applications',
      path: '${RouteNames.shellPath}/${RouteNames.applicationsPath}',
    ),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      path: '${RouteNames.shellPath}/${RouteNames.profilePath}',
    ),
  ];

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (loc.startsWith(_navItems[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: selectedIndex,
        onTap: (i) {
          if (i != selectedIndex) {
            HapticFeedback.selectionClick();
            context.go(_navItems[i].path);
          }
        },
        items: _navItems
            .map(
              (e) => BottomNavItem(
                icon: e.icon,
                activeIcon: e.activeIcon,
                label: e.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
