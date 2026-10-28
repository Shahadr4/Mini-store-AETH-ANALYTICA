import 'dart:convert';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/prefs_service.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  List<CartItemModel> getItems();
  Future<void> saveItems(List<CartItemModel> items);
  Future<void> clear();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  const CartLocalDataSourceImpl(this._prefs);

  final PrefsService _prefs;

  @override
  List<CartItemModel> getItems() {
    final raw = _prefs.getString(StorageKeys.cart);
    if (raw == null || raw.isEmpty) return const [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveItems(List<CartItemModel> items) async {
    await _prefs.setString(
      StorageKeys.cart,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(StorageKeys.cart);
  }
}
