import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../domain/entities/product_sort.dart';
import '../provider/product_list_provider.dart';
import '../widgets/paged_product_grid.dart';

extension on ProductSort {
  String get label => switch (this) {
    ProductSort.none => 'Default',
    ProductSort.priceLowToHigh => 'Price: Low to High',
    ProductSort.priceHighToLow => 'Price: High to Low',
    ProductSort.topRated => 'Top Rated',
  };
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => sl<ProductListProvider>()..loadFirstPage(),
    child: const _HomeView(),
  );
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _refresh(ProductListProvider provider) async {
    final error = await provider.refresh();
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductListProvider>();
    return Scaffold(
      // The header lives outside the scroll view, so it stays pinned.
      body: Column(
        children: [
          ListenableBuilder(
            listenable: _searchFocus,
            builder: (context, _) => _HomeHeader(
              controller: _searchController,
              focusNode: _searchFocus,
              // Greeting folds away while typing to leave room for results.
              compact: _searchFocus.hasFocus,
              onChanged: provider.search,
              onClear: () {
                _searchController.clear();
                provider.clearSearch();
              },
            ),
          ),
          Expanded(
            child: Consumer<ProductListProvider>(
              builder: (context, products, _) => PagedProductGrid(
                provider: products,
                onRefresh: () => _refresh(provider),
                emptyTitle: products.query.isEmpty
                    ? 'No products yet'
                    : 'No results for "${products.query}"',
                emptyMessage: products.query.isEmpty
                    ? null
                    : 'Try a different search term.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.controller,
    required this.focusNode,
    required this.compact,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool compact;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final name = context.select<AuthProvider, String?>(
      (auth) => auth.user?.firstName,
    );
    return BrandHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: compact
                ? const SizedBox(width: double.infinity)
                : _greeting(context, name),
          ),
          Row(
            children: [
              Expanded(
                child: _SearchField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  onClear: onClear,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              const _SortButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _greeting(BuildContext context, String? name) {
    final onPrimary = context.colors.onPrimary;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name == null || name.isEmpty ? 'Hello!' : 'Hello, $name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.titleLarge!.copyWith(
                      color: onPrimary,
                    ),
                  ),
                  Text(
                    'Find something you will love',
                    style: context.captionStyle.copyWith(
                      color: onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: AppLogo(size: 36),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
      ],
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductListProvider>();
    return Selector<ProductListProvider, ProductSort>(
      selector: (_, products) => products.sort,
      builder: (context, sort, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        child: PopupMenuButton<ProductSort>(
          tooltip: 'Sort',
          initialValue: sort,
          onSelected: provider.setSort,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: Badge(
            isLabelVisible: sort != ProductSort.none,
            smallSize: 8,
            child: Icon(Icons.tune_rounded, color: context.colors.primary),
          ),
          itemBuilder: (_) => [
            for (final option in ProductSort.values)
              CheckedPopupMenuItem(
                value: option,
                checked: option == sort,
                child: Text(option.label),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: 'Search products',
      prefixIcon: const Icon(Icons.search_rounded),
      border: _noBorder,
      enabledBorder: _noBorder,
      focusedBorder: _noBorder,
      suffixIcon: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => value.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded),
                onPressed: onClear,
              ),
      ),
    ),
  );

  static final _noBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radius),
    borderSide: BorderSide.none,
  );
}
