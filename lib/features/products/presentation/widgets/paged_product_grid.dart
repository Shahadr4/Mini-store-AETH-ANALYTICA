import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../provider/paged_products_provider.dart';
import 'product_card.dart';

/// Product grid with the four states (loading, success, error, empty),
/// pull-to-refresh and loading more when the user scrolls near the bottom.
///
/// The parent rebuilds it when the [provider] changes (with a Consumer).
class PagedProductGrid extends StatefulWidget {
  const PagedProductGrid({
    super.key,
    required this.provider,
    required this.onRefresh,
    required this.emptyTitle,
    this.emptyMessage,
  });

  final PagedProductsProvider provider;
  final Future<void> Function() onRefresh;
  final String emptyTitle;
  final String? emptyMessage;

  @override
  State<PagedProductGrid> createState() => _PagedProductGridState();
}

class _PagedProductGridState extends State<PagedProductGrid> {
  static const _loadMoreThreshold = 300.0;
  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 220,
    mainAxisSpacing: AppSpacing.m,
    crossAxisSpacing: AppSpacing.m,
    childAspectRatio: 0.66,
  );

  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_loadMoreIfNearBottom);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadMoreIfNearBottom() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.maxScrollExtent - position.pixels <= _loadMoreThreshold) {
      widget.provider.loadMore();
    }
  }

  /// On a tall screen the first page may not fill the screen, so there is
  /// nothing to scroll. Keep loading until it does.
  void _fillViewportIfNeeded() {
    final provider = widget.provider;
    final canLoad =
        provider.status == ListStatus.success &&
        !provider.isLoadingMore &&
        !provider.hasReachedMax &&
        !provider.loadMoreFailed;
    if (!canLoad) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => mounted ? _loadMoreIfNearBottom() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    _fillViewportIfNeeded();
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: _stateSlivers(context),
      ),
    );
  }

  List<Widget> _stateSlivers(BuildContext context) {
    final provider = widget.provider;
    const padding = EdgeInsets.fromLTRB(
      AppSpacing.screenPadding,
      AppSpacing.m,
      AppSpacing.screenPadding,
      0,
    );

    switch (provider.status) {
      case ListStatus.loading:
        return [
          SliverPadding(
            padding: padding,
            sliver: SliverGrid.builder(
              gridDelegate: _gridDelegate,
              itemCount: 6,
              itemBuilder: (_, _) => const ProductCardSkeleton(),
            ),
          ),
        ];
      case ListStatus.failure:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(
              message: provider.errorMessage ?? 'Could not load products.',
              onRetry: provider.loadFirstPage,
            ),
          ),
        ];
      case ListStatus.success:
        if (provider.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyView(
                icon: Icons.search_off_rounded,
                title: widget.emptyTitle,
                message: widget.emptyMessage,
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: padding,
            sliver: SliverGrid.builder(
              gridDelegate: _gridDelegate,
              itemCount: provider.products.length,
              itemBuilder: (_, index) =>
                  ProductCard(product: provider.products[index]),
            ),
          ),
          SliverToBoxAdapter(child: _Footer(provider: provider)),
        ];
    }
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.provider});

  final PagedProductsProvider provider;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (provider.isLoadingMore) {
      child = const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    } else if (provider.loadMoreFailed) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              provider.errorMessage ?? 'Could not load more products.',
              style: context.captionStyle,
              textAlign: TextAlign.center,
            ),
          ),
          TextButton.icon(
            onPressed: provider.loadMore,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      );
    } else if (provider.hasReachedMax) {
      child = Text("You've seen it all", style: context.captionStyle);
    } else {
      child = const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
      child: Center(child: child),
    );
  }
}
