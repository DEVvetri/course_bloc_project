import 'package:demo_course_app/core/data/product/models/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products; // full data
  final List<ProductModel> filteredProducts; // filtered data
  final String selectedFilter;
final String? searchQuery;
  ProductLoaded({
    required this.products,
    required this.filteredProducts,
    this.selectedFilter ='All',
    this.searchQuery=null
  });

  /// copyWith for easy updates
  ProductLoaded copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    String? selectedFilter,
    String? searchQuery,

  }) {
    return ProductLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedFilter: selectedFilter ?? this.selectedFilter ,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}

