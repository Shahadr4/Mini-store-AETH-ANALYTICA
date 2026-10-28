import 'package:flutter/material.dart';

/// The Mini Store logo (same artwork as the launcher icon).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/logo.png',
    width: size,
    height: size,
    semanticLabel: 'Mini Store logo',
  );
}
