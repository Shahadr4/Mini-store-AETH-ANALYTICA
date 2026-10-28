import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../products/presentation/widgets/paged_product_grid.dart';
import '../provider/category_products_provider.dart';

class CategoryProductsPage extends StatelessWidget {
  const CategoryProductsPage({super.key, required this.slug, this.title});

  final String slug;

  /// Display name; falls back to the slug when opened without one.
  final String? title;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => sl<CategoryProductsProvider>()..start(slug),
    child: Scaffold(
      appBar: AppBar(title: Text(title ?? prettifySlug(slug))),
      body: const _CategoryProductsBody(),
    ),
  );
}

class _CategoryProductsBody extends StatelessWidget {
  const _CategoryProductsBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CategoryProductsProvider>();
    return Consumer<CategoryProductsProvider>(
      builder: (context, products, _) => PagedProductGrid(
        provider: products,
        onRefresh: () async {
          final error = await provider.refresh();
          if (error != null && context.mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(error)));
          }
        },
        emptyTitle: 'No products in this category',
      ),
    );
  }
}
