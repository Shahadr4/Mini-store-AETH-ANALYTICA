import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

/// Search box with a clear (x) button that appears only while it has text.
///
/// By default it has no border (it sits on the primary header of Home).
/// With [bordered] it uses the normal input border of the theme.
class ProductSearchField extends StatelessWidget {
  const ProductSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.focusNode,
    this.hint = 'Search products',
    this.bordered = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hint;
  final bool bordered;

  static final _noBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radius),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search_rounded),
      border: bordered ? null : _noBorder,
      enabledBorder: bordered ? null : _noBorder,
      focusedBorder: bordered ? null : _noBorder,
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
}
