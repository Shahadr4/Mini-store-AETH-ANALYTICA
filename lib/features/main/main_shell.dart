import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_context.dart';
import '../cart/presentation/provider/cart_provider.dart';

/// Scaffold with the bottom navigation bar: Home, Categories, Cart, Account.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: DecoratedBox(
      decoration: BoxDecoration(boxShadow: context.softShadowUp),
      child: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the current tab again returns to its first screen.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category_rounded),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: const _CartIcon(selected: false),
            selectedIcon: const _CartIcon(selected: true),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    ),
  );
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Selector<CartProvider, int>(
    selector: (_, cart) => cart.totalQuantity,
    builder: (context, count, _) => Badge.count(
      count: count,
      isLabelVisible: count > 0,
      child: Icon(
        selected ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined,
      ),
    ),
  );
}
