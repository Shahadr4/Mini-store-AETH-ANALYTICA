import 'package:flutter/material.dart';

/// Icon for a DummyJSON category slug. Falls back to a generic icon.
IconData iconForCategory(String slug) {
  const icons = <String, IconData>{
    'beauty': Icons.spa_outlined,
    'fragrances': Icons.local_florist_outlined,
    'furniture': Icons.chair_outlined,
    'groceries': Icons.local_grocery_store_outlined,
    'home-decoration': Icons.weekend_outlined,
    'kitchen-accessories': Icons.kitchen_outlined,
    'laptops': Icons.laptop_mac_rounded,
    'mens-shirts': Icons.checkroom_outlined,
    'mens-shoes': Icons.directions_walk_rounded,
    'mens-watches': Icons.watch_outlined,
    'mobile-accessories': Icons.headphones_outlined,
    'motorcycle': Icons.two_wheeler_rounded,
    'skin-care': Icons.face_retouching_natural_outlined,
    'smartphones': Icons.smartphone_rounded,
    'sports-accessories': Icons.sports_basketball_outlined,
    'sunglasses': Icons.wb_sunny_outlined,
    'tablets': Icons.tablet_mac_rounded,
    'tops': Icons.checkroom_outlined,
    'vehicle': Icons.directions_car_outlined,
    'womens-bags': Icons.shopping_bag_outlined,
    'womens-dresses': Icons.dry_cleaning_outlined,
    'womens-jewellery': Icons.diamond_outlined,
    'womens-shoes': Icons.directions_walk_rounded,
    'womens-watches': Icons.watch_outlined,
  };
  return icons[slug] ?? Icons.category_outlined;
}
