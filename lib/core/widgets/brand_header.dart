import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_spacing.dart';
import '../theme/theme_context.dart';

/// Primary-coloured header with rounded bottom corners and soft decorative
/// circles. Used at the top of Login, Home and Account.
class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.screenPadding,
      AppSpacing.m,
      AppSpacing.screenPadding,
      AppSpacing.l,
    ),
  });

  static const double _radius = 24;

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    const shape = BorderRadius.vertical(bottom: Radius.circular(_radius));
    final tint = context.colors.onPrimary.withValues(alpha: 0.08);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: shape,
          boxShadow: context.softShadow,
        ),
        child: ClipRRect(
          borderRadius: shape,
          child: Stack(
            children: [
              Positioned(
                top: -48,
                right: -40,
                child: _Circle(size: 176, color: tint),
              ),
              Positioned(
                bottom: -64,
                left: -32,
                child: _Circle(size: 144, color: tint),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: padding,
                  child: SizedBox(width: double.infinity, child: child),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
