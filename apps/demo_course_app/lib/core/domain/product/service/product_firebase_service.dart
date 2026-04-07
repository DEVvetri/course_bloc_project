import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_course_app/core/data/product/models/product_model.dart';
import 'package:demo_course_app/core/data_storage/product/service/app_logger.dart';

class ProductFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.productId)
          .set(product.toMap());

      AppLogger.log("Firebase add success: ${product.productId}");
    } catch (e) {
      AppLogger.error("Firebase add failed", e);
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.productId)
          .update(product.toMap());

      AppLogger.log("Firebase update success: ${product.productId}");
    } catch (e) {
      AppLogger.error("Firebase update failed", e);
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();

      AppLogger.log("Firebase delete success: $productId");
    } catch (e) {
      AppLogger.error("Firebase delete failed", e);
      rethrow;
    }
  }
  Future<List<ProductModel>> getAllProducts() async {
  try {
    final snapshot = await _firestore.collection('products').get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    AppLogger.error("Firebase fetch failed", e);
    rethrow;
  }
}
}