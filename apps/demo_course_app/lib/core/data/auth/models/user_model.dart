class AuthUserModel {
  final String uid;
  final String? email;

  AuthUserModel({required this.uid, this.email});
}

class UserModel {
  final String userId;
  final String name;
  final String email;
  final List<String> cartProductIds;
  final String address;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.cartProductIds,
    required this.address,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      cartProductIds: List<String>.from(map['cart_product_ids'] ?? []),
      address: map['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'cart_product_ids': cartProductIds,
      'address': address,
    };
  }
}