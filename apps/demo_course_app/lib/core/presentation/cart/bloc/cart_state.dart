import 'package:demo_course_app/core/data/product/models/cart_product_model.dart';

abstract class CartState {}

class CartLoading extends CartState {}

class CartInitial extends CartState {}

class CartLoaded extends CartState {
  final List<CartProductModel> cart;
  CartLoaded(this.cart);
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}