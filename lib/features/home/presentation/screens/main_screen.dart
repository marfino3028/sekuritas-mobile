import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.portfolio)) return 1;
    if (location.startsWith(AppRoutes.explore)) return 2;
    if (location.startsWith(AppRoutes.transaction)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0; // home
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.portfolio);
        break;
      case 2:
        context.go(AppRoutes.explore);
        break;
      case 3:
        context.go(AppRoutes.transaction);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
    );
  }
}
