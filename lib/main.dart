import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/account/presentation/provider/theme_provider.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/cart/presentation/provider/cart_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initDependencies();
  runApp(const MiniStoreApp());
}

class MiniStoreApp extends StatelessWidget {
  const MiniStoreApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    // App-wide providers live in get_it as singletons, hence `.value`.
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: sl<AuthProvider>()),
      ChangeNotifierProvider<CartProvider>.value(
        value: sl<CartProvider>()..load(),
      ),
      ChangeNotifierProvider<ThemeProvider>.value(value: sl<ThemeProvider>()),
    ],
    child: Consumer<ThemeProvider>(
      builder: (context, theme, _) => MaterialApp.router(
        title: 'Mini Store',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: theme.mode,
        routerConfig: sl<GoRouter>(),
        // Status bar icons follow the theme (screens with a brand header or
        // an app bar override this for themselves).
        builder: (context, child) {
          final isLight = Theme.of(context).brightness == Brightness.light;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value:
                (isLight
                        ? SystemUiOverlayStyle.dark
                        : SystemUiOverlayStyle.light)
                    .copyWith(statusBarColor: Colors.transparent),
            child: child!,
          );
        },
      ),
    ),
  );
}
