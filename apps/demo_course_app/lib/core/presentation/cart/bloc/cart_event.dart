import 'package:demo_course_app/core/data/product/models/cart_product_model.dart';

abstract class CartEvent {}

class LoadCart extends CartEvent {
 
}
class AddCartProduct extends CartEvent {
  final CartProductModel product;
  AddCartProduct(this.product);
}

class RemoveProduct extends CartEvent {
  final String productId;
  RemoveProduct(this.productId);
}
class IncreaseQuantity extends CartEvent {
  final String productId;
  IncreaseQuantity(this.productId);
}

class DecreaseQuantity extends CartEvent {
  final String productId;
  DecreaseQuantity(this.productId);
}
class SyncCart extends CartEvent {}

class SyncCartFromFirebase extends CartEvent {}