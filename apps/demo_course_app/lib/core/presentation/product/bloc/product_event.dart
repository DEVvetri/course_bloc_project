import 'package:demo_course_app/core/data/product/models/product_model.dart';

abstract class ProductEvent {}

class LoadProducts extends ProductEvent {}

class AddProduct extends ProductEvent {
  final ProductModel product;
  AddProduct(this.product);
}

class UpdateProduct extends ProductEvent {
  final ProductModel product;
  UpdateProduct(this.product);
}

class DeleteProduct extends ProductEvent {
  final String productId;
  DeleteProduct(this.productId);
}
class SearchProducts extends ProductEvent {
  final String query;
  SearchProducts(this.query);
}

class FilterByCategory extends ProductEvent {
  final String category;
  FilterByCategory(this.category);
}

class ClearFilters extends ProductEvent {}
class SyncPendingProducts extends ProductEvent {}
class SyncProducts extends ProductEvent {}