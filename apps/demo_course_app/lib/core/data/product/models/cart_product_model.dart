class CartProductModel {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  // 🔥 Sync fields
  final bool isSynced;
  final bool isDeleted;
  final int updatedAt; // timestamp

  CartProductModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.isSynced = false,
    this.isDeleted = false,
    required this.updatedAt,
  });

  CartProductModel copyWith({
    String? productId,
    String? name,
    double? price,
    int? quantity,
    bool? isSynced,
    bool? isDeleted,
    int? updatedAt,
  }) {
    return CartProductModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'updatedAt': updatedAt,
    };
  }

  factory CartProductModel.fromMap(Map<String, dynamic> map) {
    return CartProductModel(
      productId: map['productId'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      isSynced: map['isSynced'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      updatedAt: map['updatedAt'] ?? 0,
    );
  }
}