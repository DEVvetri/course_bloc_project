import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_course_app/core/data_storage/cart/services/cart_hive_service.dart';
import 'package:demo_course_app/core/domain/cart/service/cart_sync.dart';

import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartHiveService hiveService;
  final CartSyncService syncService;

  // Safe UID getter to prevent crashes during logout or transition phases
  String? get _safeUid => FirebaseAuth.instance.currentUser?.uid;

  CartBloc(this.hiveService, this.syncService) : super(CartInitial()) {
    on<LoadCart>(_onLoad);
    on<AddCartProduct>(_onAdd);
    on<RemoveProduct>(_onRemove);
    on<IncreaseQuantity>(_onIncrease);
    on<DecreaseQuantity>(_onDecrease);
    on<SyncCart>(_onSync);
    on<SyncCartFromFirebase>(_onSyncFromFirebase);
  }

  /// Initial Local Load - Non-blocking (Fast UI)
  void _onLoad(LoadCart event, Emitter<CartState> emit) {
    final uid = _safeUid;
    if (uid == null) return emit(CartError("User not authenticated"));

    log('CartBloc: Loading local Hive cart for $uid');
    final cart = hiveService.getCart(uid);
    emit(CartLoaded(cart));
  }

  /// Pull from Firebase - Typically used on App Start or Refresh
  Future<void> _onSyncFromFirebase(
    SyncCartFromFirebase event,
    Emitter<CartState> emit,
  ) async {
    final uid = _safeUid;
    if (uid == null) return;

    emit(CartLoading()); // Optional: show spinner for full refresh
    try {
      log('CartBloc: Pulling from Firebase...');
      await syncService.pull(uid);
      emit(CartLoaded(hiveService.getCart(uid)));
    } catch (e) {
      log('CartBloc Error (Pull): $e');
      emit(CartError("Failed to sync with server. Viewing offline data."));
      // Still show local data even if pull fails
      emit(CartLoaded(hiveService.getCart(uid)));
    }
  }

  Future<void> _onAdd(AddCartProduct event, Emitter<CartState> emit) async {
    final uid = _safeUid;
    if (uid == null) return;

    try {
      await hiveService.addOrUpdateProduct(uid, event.product);
      emit(CartLoaded(hiveService.getCart(uid)));
      add(SyncCart()); // Trigger background push
    } catch (e) {
      emit(CartError("Failed to update cart locally."));
    }
  }

  Future<void> _onRemove(RemoveProduct event, Emitter<CartState> emit) async {
    final uid = _safeUid;
    if (uid == null) return;

    await hiveService.removeProduct(uid, event.productId);
    emit(CartLoaded(hiveService.getCart(uid)));
    add(SyncCart());
  }

  Future<void> _onIncrease(IncreaseQuantity event, Emitter<CartState> emit) async {
    final uid = _safeUid;
    if (uid == null) return;

    await hiveService.increaseQuantity(uid, event.productId);
    emit(CartLoaded(hiveService.getCart(uid)));
    add(SyncCart());
  }

  Future<void> _onDecrease(DecreaseQuantity event, Emitter<CartState> emit) async {
    final uid = _safeUid;
    if (uid == null) return;

    await hiveService.decreaseQuantity(uid, event.productId);
    emit(CartLoaded(hiveService.getCart(uid)));
    add(SyncCart());
  }

  /// Background Push Sync
  Future<void> _onSync(SyncCart event, Emitter<CartState> emit) async {
    final uid = _safeUid;
    if (uid == null) return;

    try {
      log('CartBloc: Pushing pending changes to Firebase...');
      await syncService.sync(uid);
      
      emit(CartLoaded(hiveService.getCart(uid)));
    } catch (e) {
      log('CartBloc Error (Push Sync): $e');
      emit(CartError("Failed to sync with server."));
    }
  }
}