import 'package:demo_course_app/core/presentation/product/bloc/product_event.dart';
import 'package:demo_course_app/core/presentation/product/bloc/product_state.dart';
import 'package:demo_course_app/core/data/product/models/product_model.dart';
import 'package:demo_course_app/core/data_storage/product/service/app_logger.dart';
import 'package:demo_course_app/core/domain/product/service/product_firebase_service.dart';
import 'package:demo_course_app/core/data_storage/product/service/product_local_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductHiveService hiveService;
  final ProductFirebaseService firebaseService;

  ProductBloc({required this.hiveService, required this.firebaseService})
    : super(ProductInitial()) {
    on<SyncProducts>(_onSync);
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SyncPendingProducts>(_onSyncPending);
    on<SearchProducts>(_onSearchProducts);
    on<FilterByCategory>(_onFilterByCategory);
    on<ClearFilters>(_onClearFilters);
  }
  Future<void> _onSync(SyncProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());

    await syncFromFirebaseToHive();

    final localData = await hiveService.getAll();

    emit(
      ProductLoaded(
        products: localData,
        filteredProducts: localData,
        selectedFilter: 'All',
        searchQuery: null,
      ),
    );
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final products = await hiveService.getAll();
      emit(
        ProductLoaded(
          products: products,
          filteredProducts: products,
          selectedFilter: 'All',
          searchQuery: null,
        ),
      );
    } catch (e) {
      AppLogger.error("LoadProducts failed", e);
      emit(ProductError("Failed to load products"));
    }
  }

  Future<void> syncFromFirebaseToHive() async {
    try {
      // 1. Fetch from Firebase
      final remoteProducts = await firebaseService.getAllProducts();

      // 2. Replace local Hive data
      await hiveService.replaceAll(remoteProducts);

      AppLogger.log("Sync completed");
    } catch (e) {
      AppLogger.error("Sync failed", e);
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    final product = event.product.copyWith(isSynced: false, action: "add");

    try {
      await hiveService.add(product);
      add(LoadProducts());

      await firebaseService.addProduct(product);

      final updated = product.copyWith(isSynced: true, action: "");
      await hiveService.update(updated);
      add(LoadProducts());
    } catch (e) {
      AppLogger.error("AddProduct failed", e);
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    final product = event.product.copyWith(isSynced: false, action: "update");

    try {
      await hiveService.update(product);
      add(LoadProducts());

      await firebaseService.updateProduct(product);

      final updated = product.copyWith(isSynced: true, action: "");
      await hiveService.update(updated);
      add(LoadProducts());
    } catch (e) {
      AppLogger.error("UpdateProduct failed", e);
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await hiveService.delete(event.productId);
      add(LoadProducts());

      await firebaseService.deleteProduct(event.productId);

      await hiveService.deletePermanent(event.productId);
      add(LoadProducts());
    } catch (e) {
      AppLogger.error("DeleteProduct failed", e);
    }
  }

  Future<void> _onSyncPending(
    SyncPendingProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final pending = await hiveService.getPendingProducts();

      for (var product in pending) {
        try {
          if (product.action == "add") {
            await firebaseService.addProduct(product);
          } else if (product.action == "update") {
            await firebaseService.updateProduct(product);
          } else if (product.action == "delete") {
            await firebaseService.deleteProduct(product.productId);
            await hiveService.deletePermanent(product.productId);
            continue;
          }

          final updated = product.copyWith(isSynced: true, action: "");

          await hiveService.update(updated);
        } catch (e) {
          AppLogger.error("Sync failed for ${product.productId}", e);
          break;
        }
      }

      add(LoadProducts());
    } catch (e) {
      AppLogger.error("SyncPendingProducts failed", e);
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductLoaded) return;

    final current = state as ProductLoaded;

    final updatedState = current.copyWith(
      searchQuery: event.query, // can be empty
    );

    emit(updatedState.copyWith(filteredProducts: _applyFilters(updatedState)));
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductLoaded) return;

    final current = state as ProductLoaded;

    final updatedState = current.copyWith(selectedFilter: event.category);

    emit(updatedState.copyWith(filteredProducts: _applyFilters(updatedState)));
  }

  List<ProductModel> _applyFilters(ProductLoaded state) {
    var list = state.products;

    // ✅ Category filter (ONLY if selected)
    if (state.selectedFilter != 'All') {
      list = list.where((p) => p.category == state.selectedFilter).toList();
    }

    // ✅ Search filter
    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      final query = state.searchQuery!.toLowerCase();

      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.category.toLowerCase().contains(query),
          )
          .toList();
    }

    return list;
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductLoaded) return;

    final current = state as ProductLoaded;

    emit(
      current.copyWith(
        selectedFilter: 'All',
        searchQuery: null,
        filteredProducts: current.products,
      ),
    );
  }
}
