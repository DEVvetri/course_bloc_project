import 'package:demo_course_app/core/data/product/models/product_hive.dart';

class ProductModel {
  final String productId;
  final String name;
  final String category;
  final double price;
  final String image;
  final double rating;
  final bool isSynced;
  final String action;
  ProductModel({
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.rating,
    this.action = 'add',
    this.isSynced = false,
  });
  ProductModel copyWith({
    String? productId,
    String? name,
    String? category,
    double? price,
    String? image,
    double? rating,
    bool? isSynced,
    String? action,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      isSynced: isSynced ?? this.isSynced,
      action: action ?? this.action,
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['product_id'],
      name: map['name'],
      category: map['category'],
      price: (map['price'] as num).toDouble(),
      image: map['image'],
      rating: (map['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'name': name,
      'category': category,
      'price': price,
      'image': image,
      'rating': rating,
    };
  }

  static final List<ProductModel> demoProducts = [
    ProductModel(
      productId: '001',
      name: "Wireless Headphones",
      category: "Electronics",
      price: 199.99,
      image: "🎧",
      rating: 4.8,
    ),
    ProductModel(
      productId: '002',
      name: "Leather Watch",
      category: "Accessories",
      price: 120.50,
      image: "⌚",
      rating: 4.5,
    ),
    ProductModel(
      productId: '003',
      name: "Running Shoes",
      category: "Fashion",
      price: 89.99,
      image: "👟",
      rating: 4.7,
    ),
    ProductModel(
      productId: '004',
      name: "Coffee Machine",
      category: "Home",
      price: 250.00,
      image: "☕",
      rating: 4.9,
    ),
    ProductModel(
      productId: '005',
      name: "Backpack",
      category: "Travel",
      price: 45.00,
      image: "🎒",
      rating: 4.2,
    ),
    ProductModel(
      productId: '006',
      name: "Gaming Mouse",
      category: "Electronics",
      price: 59.99,
      image: "🖱️",
      rating: 4.6,
    ),
  ];
}

extension ProductMapper on ProductModel {
  ProductHiveModel toHiveModel() {
    return ProductHiveModel(
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
