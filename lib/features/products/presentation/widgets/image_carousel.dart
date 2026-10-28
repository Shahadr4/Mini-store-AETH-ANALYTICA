import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_network_image.dart';

/// Swipeable product images with dot indicators.
///
/// [topInset] leaves room for the status bar and the floating app bar, and
/// the bottom keeps space for the info panel that overlaps the carousel.
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key, required this.images, this.topInset = 0});

  static const double overlap = AppSpacing.l;

  final List<String> images;
  final double topInset;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return ColoredBox(
      color: context.colors.outline.withValues(alpha: 0.3),
      child: Column(
        children: [
          SizedBox(height: widget.topInset),
          SizedBox(
            height: 280,
            child: PageView.builder(
              controller: _controller,
              itemCount: images.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: AppNetworkImage(url: images[index], fit: BoxFit.contain),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
            child: images.length > 1
                ? SmoothPageIndicator(
                    controller: _controller,
                    count: images.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      activeDotColor: context.colors.primary,
                      dotColor: context.appColors.border,
                    ),
                  )
                : const SizedBox(height: 8),
          ),
          const SizedBox(height: ImageCarousel.overlap),
        ],
      ),
    );
  }
}
