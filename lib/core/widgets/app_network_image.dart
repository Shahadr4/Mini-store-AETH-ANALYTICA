import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import 'shimmer_box.dart';

/// Network image with a shimmer placeholder and an error icon.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final placeholder = ShimmerBox(width: width, height: height, radius: 0);
    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) return _error(context);
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => _error(context),
    );
  }

  Widget _error(BuildContext context) => Container(
    width: width,
    height: height,
    color: context.appColors.border,
    alignment: Alignment.center,
    child: Icon(
      Icons.broken_image_outlined,
      color: context.appColors.textSecondary,
    ),
  );
}
