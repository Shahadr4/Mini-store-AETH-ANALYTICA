/// Sort options for the product list (`sortBy` / `order` query parameters).
enum ProductSort {
  none(null, null),
  priceLowToHigh('price', 'asc'),
  priceHighToLow('price', 'desc'),
  topRated('rating', 'desc');

  const ProductSort(this.sortBy, this.order);

  final String? sortBy;
  final String? order;
}
