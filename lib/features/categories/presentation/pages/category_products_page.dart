import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../products/presentation/widgets/paged_product_grid.dart';
import '../../../products/presentation/widgets/product_search_field.dart';
import '../../../products/presentation/widgets/product_sort_button.dart';
import '../provider/category_products_provider.dart';

class CategoryProductsPage extends StatelessWidget {
  const CategoryProductsPage({super.key, required this.slug, this.title});

  final String slug;

  /// Display name; falls back to the slug when opened without one.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final name = title ?? prettifySlug(slug);
    return ChangeNotifierProvider(
      create: (_) => sl<CategoryProductsProvider>()..start(slug),
      child: Scaffold(
        appBar: AppBar(title: Text(name)),
        body: _CategoryProductsBody(categoryName: name),
      ),
    );
  }
}

class _CategoryProductsBody extends StatefulWidget {
  const _CategoryProductsBody({required this.categoryName});

  final String categoryName;

  @override
  State<_CategoryProductsBody> createState() => _CategoryProductsBodyState();
}

class _CategoryProductsBodyState extends State<_CategoryProductsBody> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh(CategoryProductsProvider provider) async {
    final error = await provider.refresh();
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CategoryProductsProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.s,
            AppSpacing.screenPadding,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: ProductSearchField(
                  controller: _searchController,
                  hint: 'Search in ${widget.categoryName}',
                  bordered: true,
                  onChanged: provider.search,
                  onClear: () {
                    _searchController.clear();
                    provider.clearSearch();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              const ProductSortButton<CategoryProductsProvider>(bordered: true),
            ],
          ),
        ),
        Expanded(
          child: Consumer<CategoryProductsProvider>(
            builder: (context, products, _) => PagedProductGrid(
              provider: products,
              onRefresh: () => _refresh(provider),
              emptyTitle: products.query.isEmpty
                  ? 'No products in this category'
                  : 'No results for "${products.query}"',
              emptyMessage: products.query.isEmpty
                  ? null
                  : 'Try a different search term.',
            ),
          ),
        ),
      ],
    );
  }
}
