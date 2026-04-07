import 'dart:developer';
import 'package:demo_course_app/core/domain/cart/service/cart_firebase_service.dart';
import 'package:demo_course_app/core/data_storage/cart/services/cart_hive_service.dart';

class CartSyncService {
  final CartHiveService hiveService;
  final CartFirebaseService firebaseService;

  CartSyncService(this.hiveService, this.firebaseService);

  Future<void> sync(String userId) async {
    log('SyncService: Starting push sync for user $userId');
    
    try {
      final pending = await hiveService.getPendingSync(userId);

      if (pending.isEmpty) {
        log('SyncService: No pending items to sync.');
        return;
      }

      for (final item in pending) {
        try {
          // 1. Try to update the remote database
          await firebaseService.syncProduct(userId, item);
          
          // 2. If successful, clear the pending flag in Hive
          await hiveService.markSynced(userId, item.productId);
          
          log('SyncService: Successfully synced product ${item.productId}');
        } catch (e) {
          log('SyncService: Failed to sync product ${item.productId}. Stopping batch. Error: $e');
          rethrow; 
        }
      }
    } catch (e) {
      log('SyncService Critical Error (sync): $e');
      rethrow;
    }
  }

  /// Pulls the latest cart state from Firebase and overwrites local Hive storage.
  Future<void> pull(String userId) async {
    log('SyncService: Pulling remote cart for user $userId');
    
    try {
      // 1. Fetch from Firebase
      final serverCart = await firebaseService.fetchCart();
      
      // 2. Atomically update Hive to prevent partial data states
      await hiveService.saveCart(userId, serverCart);
      
      log('SyncService: Local Hive storage updated with ${serverCart.length} items');
    } catch (e) {
      log('SyncService Critical Error (pull): $e');
   
      rethrow;
    }
  }
}