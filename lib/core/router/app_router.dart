import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/presentation/pages/account_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/provider/auth_provider.dart';
import '../../features/cart/domain/entities/order_summary.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/order_success_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/categories/presentation/pages/category_products_page.dart';
import '../../features/main/main_shell.dart';
import '../../features/products/presentation/pages/home_page.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Navigation is driven by [AuthProvider]: the redirect sends the user to
  /// Splash, Login or Main whenever the session state changes.
  ///
  /// Splash, Login and Main are top-level routes opened with `go`, so each is
  /// the only page in the stack and Back closes the app. After logout the
  /// stack is replaced, so Main cannot be reached with Back.
  static GoRouter create(AuthProvider authProvider) => GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authProvider,
    redirect: (context, state) => _redirect(authProvider.status, state),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.categories,
                builder: (_, _) => const CategoriesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                builder: (_, _) => const CartPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.account,
                builder: (_, _) => const AccountPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.categoryProductsPattern,
        builder: (_, state) => CategoryProductsPage(
          slug: state.pathParameters['slug']!,
          title: state.extra as String?,
        ),
      ),
      GoRoute(
        path: AppRoutes.productDetailsPattern,
        redirect: (_, state) =>
            int.tryParse(state.pathParameters['id'] ?? '') == null
            ? AppRoutes.home
            : null,
        builder: (_, state) => ProductDetailsPage(
          productId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        // The summary is passed as `extra`; without it there is nothing to show.
        redirect: (_, state) =>
            state.extra is OrderSummary ? null : AppRoutes.home,
        builder: (_, state) =>
            OrderSuccessPage(order: state.extra! as OrderSummary),
      ),
    ],
  );

  static String? _redirect(AuthStatus authStatus, GoRouterState state) {
    final location = state.matchedLocation;
    switch (authStatus) {
      case AuthStatus.unknown:
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      case AuthStatus.unauthenticated:
        return location == AppRoutes.login ? null : AppRoutes.login;
      case AuthStatus.authenticated:
        final onEntryScreen =
            location == AppRoutes.splash || location == AppRoutes.login;
        return onEntryScreen ? AppRoutes.home : null;
    }
  }
}
