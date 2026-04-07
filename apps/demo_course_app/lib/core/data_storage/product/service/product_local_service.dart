import 'package:demo_course_app/core/data/product/models/product_hive.dart';
import 'package:demo_course_app/core/data/product/models/product_model.dart';
import 'package:demo_course_app/core/data_storage/product/service/app_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProductHiveService {
  final Box<ProductHiveModel> box;

  ProductHiveService(this.box);
Future<void> replaceAll(List<ProductModel> products) async {
  try {
    await box.clear(); // 🔥 clear old data

    final map = {
      for (var product in products)
        product.productId: product.toHiveModel(),
    };

    await box.putAll(map);

    AppLogger.log("Hive replaced with ${products.length} products");
  } catch (e) {
    AppLogger.error("Hive replaceAll failed", e);
    rethrow;
  }
}
  Future<List<ProductModel>> getAll() async {
    try {
      final data = box.values.toList();
      return data.map((e) => e.toDomain()).toList();
    } catch (e) {
      AppLogger.error("Hive getAll failed", e);
      rethrow;
    }
  }

  Future<ProductModel?> getById(String id) async {
    try {
      final item = box.get(id);
      return item?.toDomain();
    } catch (e) {
      AppLogger.error("Hive getById failed", e);
      return null;
    }
  }

  Future<void> add(ProductModel product) async {
    try {
      await box.put(product.productId, product.toHiveModel());
      AppLogger.log("Product added locally: ${product.productId}");
    } catch (e) {
      AppLogger.error("Hive add failed", e);
      rethrow;
    }
  }

  Future<void> update(ProductModel product) async {
    try {
      await box.put(product.productId, product.toHiveModel());
      AppLogger.log("Product updated locally: ${product.productId}");
    } catch (e) {
      AppLogger.error("Hive update failed", e);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      final item = box.get(id);
      if (item != null) {
        item.isSynced = false;
        item.action = "delete";
        await item.save();
        AppLogger.log("Product marked for delete: $id");
      }
    } catch (e) {
      AppLogger.error("Hive delete failed", e);
      rethrow;
    }
  }

  Future<void> deletePermanent(String id) async {
    try {
      await box.delete(id);
      AppLogger.log("Product deleted permanently: $id");
    } catch (e) {
      AppLogger.error("Hive permanent delete failed", e);
    }
  }

  Future<List<ProductModel>> getPendingProducts() async {
    try {
      return box.values
          .where((e) => !e.isSynced)
          .map((e) => e.toDomain())
          .toList();
    } catch (e) {
      AppLogger.error("Hive pending fetch failed", e);
      return [];
    }
  }
}
