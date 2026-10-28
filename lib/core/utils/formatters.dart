String formatPrice(double value) => '\$${value.toStringAsFixed(2)}';

/// "mens-shirts" -> "Mens Shirts"
String prettifySlug(String slug) => slug
    .split('-')
    .where((part) => part.isNotEmpty)
    .map((part) => part[0].toUpperCase() + part.substring(1))
    .join(' ');
