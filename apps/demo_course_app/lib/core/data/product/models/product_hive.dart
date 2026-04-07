import 'package:demo_course_app/core/data/product/models/product_model.dart';
import 'package:hive/hive.dart';

part 'product_hive.g.dart'; // ✅ ADD THIS

@HiveType(typeId: 0)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  double price;

  @HiveField(4)
  String image;

  @HiveField(5)
  double rating;

  @HiveField(6)
  bool isSynced;

  @HiveField(7)
  String action;

  ProductHiveModel({
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.rating,
    this.isSynced = false,
    this.action = 'add',
  });
}

extension ProductHiveMapper on ProductHiveModel {
  ProductModel toDomain() {
    return ProductModel(
      productId: productId,
      name: name,
      category: category,
      price: price,
      image: image,
      rating: rating,
      isSynced: isSynced,
      action: action,
    );
  }
}
