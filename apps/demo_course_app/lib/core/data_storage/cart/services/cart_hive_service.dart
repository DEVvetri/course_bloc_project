import 'package:demo_course_app/core/data/product/models/cart_product_model.dart';
import 'package:hive_flutter/adapters.dart';

class CartHiveService {
  final Box _box;
  CartHiveService(this._box);
  Future<void> clearCartHard(String userId) async {
    await _box.delete(userId);
  }

  Future<void> updateQuantity(
    String userId,
    String productId,
    int newQuantity,
  ) async {
    final cart = getCart(userId);

    final index = cart.indexWhere((e) => e.productId == productId);

    if (index != -1) {
      final item = cart[index];

      final updated = item.copyWith(
        quantity: newQuantity,
        isSynced: false,
        isDeleted: false,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      cart[index] = updated;
      await saveCart(userId, cart);
    }
  }

  Future<void> increaseQuantity(String userId, String productId) async {
    final cart = getCart(userId);

    final index = cart.indexWhere((e) => e.productId == productId);

    if (index != -1) {
      final item = cart[index];

      await updateQuantity(userId, productId, item.quantity + 1);
    }
  }

  Future<void> decreaseQuantity(String userId, String productId) async {
    final cart = getCart(userId);

    final index = cart.indexWhere((e) => e.productId == productId);

    if (index != -1) {
      final item = cart[index];

      if (item.quantity > 1) {
        await updateQuantity(userId, productId, item.quantity - 1);
      } else {
        // optional: soft delete
        await removeProduct(userId, productId);
      }
    }
  }

  List<CartProductModel> getCart(String userId) {
    final data = _box.get(userId);
    if (data == null) return [];

    return (data as List)
        .map((e) => CartProductModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveCart(String userId, List<CartProductModel> cart) async {
    await _box.put(userId, cart.map((e) => e.toMap()).toList());
  }

  Future<void> addOrUpdateProduct(
    String userId,
    CartProductModel product,
  ) async {
    final cart = getCart(userId);

    final index = cart.indexWhere((e) => e.productId == product.productId);

    if (index != -1) {
      // 🔥 EXISTING PRODUCT → INCREMENT
      final existing = cart[index];

      final updatedProduct = existing.copyWith(
        quantity: existing.quantity + product.quantity,
        isSynced: false,
        isDeleted: false, // revive if needed
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      cart[index] = updatedProduct;
    } else {
      // 🔥 NEW PRODUCT → ADD
      final newProduct = product.copyWith(
        isSynced: false,
        isDeleted: false,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      cart.add(newProduct);
    }

    await saveCart(userId, cart);
  }

  Future<void> removeProduct(String userId, String productId) async {
    final cart = getCart(userId);

    final index = cart.indexWhere((e) => e.productId == productId);

    if (index != -1) {
      cart[index] = cart[index].copyWith(
        isDeleted: true,
        isSynced: false,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
    }

    await saveCart(userId, cart);
  }

  // 🔥 CRITICAL: Get pending sync items
  List<CartProductModel> getPendingSync(String userId) {
    final cart = getCart(userId);

    return cart.where((e) => !e.isSynced).toList();
  }

  // 🔥 Mark as synced
  Future<void> markSynced(String userId, String productId) async {
    final cart = getCart(userId);

    final index = cart.indexWhere((e) => e.productId == productId);

    if (index != -1) {
      cart[index] = cart[index].copyWith(isSynced: true);

      // remove if deleted
      if (cart[index].isDeleted) {
        cart.removeAt(index);
      }
    }

    await saveCart(userId, cart);
  }
}
