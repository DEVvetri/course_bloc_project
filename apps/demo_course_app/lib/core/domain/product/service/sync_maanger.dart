import 'package:demo_course_app/core/domain/product/service/product_firebase_service.dart';
import 'package:demo_course_app/core/data_storage/product/service/product_local_service.dart';

class SyncService {
  final ProductHiveService hiveService;
  final ProductFirebaseService firebaseService;

  SyncService(this.hiveService, this.firebaseService);

  Future<void> syncPending() async {
    final items = await hiveService.getPendingProducts();

    for (var item in items) {
      try {
        if (item.action == 'add') {
          await firebaseService.addProduct(item);
        } else if (item.action == 'update') {
          await firebaseService.updateProduct(item);
        } else if (item.action == 'delete') {
          await firebaseService.deleteProduct(item.productId);
          await hiveService.delete(item.productId);
          continue;
        }

        //  create updated immutable object
        final updated = item.copyWith(
          isSynced: true,
          action: "",
        );

        // persist via service
        await hiveService.update(updated);

      } catch (e) {
        break; // stop if offline
      }
    }
  }
}