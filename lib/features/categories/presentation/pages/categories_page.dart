import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../domain/entities/category.dart';
import '../provider/categories_provider.dart';
import '../widgets/category_icons.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => sl<CategoriesProvider>()..load(),
    child: Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: const _CategoriesBody(),
    ),
  );
}

class _CategoriesBody extends StatelessWidget {
  const _CategoriesBody();

  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 220,
    mainAxisSpacing: AppSpacing.m,
    crossAxisSpacing: AppSpacing.m,
    mainAxisExtent: 128,
  );

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CategoriesProvider>();
    // One scroll view for every state, so pull-to-refresh also works while the
    // skeleton or an error is showing.
    return RefreshIndicator(
      onRefresh: () async {
        final error = await provider.load(refresh: true);
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error)));
        }
      },
      child: Consumer<CategoriesProvider>(
        builder: (context, categories, _) => CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: _slivers(categories),
        ),
      ),
    );
  }

  List<Widget> _slivers(CategoriesProvider provider) {
    const padding = EdgeInsets.all(AppSpacing.screenPadding);
    return switch (provider.status) {
      CategoriesStatus.loading => [
        SliverPadding(
          padding: padding,
          sliver: SliverGrid.builder(
            gridDelegate: _gridDelegate,
            itemCount: 12,
            itemBuilder: (_, _) => const ShimmerBox(),
          ),
        ),
      ],
      CategoriesStatus.failure => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(
            message: provider.errorMessage ?? 'Could not load categories.',
            onRetry: provider.load,
          ),
        ),
      ],
      CategoriesStatus.success when provider.isEmpty => [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            icon: Icons.category_outlined,
            title: 'No categories found',
          ),
        ),
      ],
      CategoriesStatus.success => [
        SliverPadding(
          padding: padding,
          sliver: SliverGrid.builder(
            gridDelegate: _gridDelegate,
            itemCount: provider.categories.length,
            itemBuilder: (_, index) =>
                _CategoryTile(category: provider.categories[index]),
          ),
        ),
      ],
    };
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: () => context.push(
      AppRoutes.categoryProducts(category.slug),
      extra: category.name,
    ),
    padding: const EdgeInsets.all(AppSpacing.m),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s + AppSpacing.xs),
            child: Icon(
              iconForCategory(category.slug),
              size: 24,
              color: context.colors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          category.name,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.labelLarge,
        ),
      ],
    ),
  );
}
