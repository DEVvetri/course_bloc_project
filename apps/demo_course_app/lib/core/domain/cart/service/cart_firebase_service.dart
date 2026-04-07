import 'dart:developer'; // For professional logging
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_course_app/core/data/product/models/cart_product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncProduct(String userId, CartProductModel product) async {
    try {
      final ref = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(product.productId);

      if (product.isDeleted) {
        log('FirebaseService: Deleting product ${product.productId} for user $userId');
        await ref.delete();
      } else {
        log('FirebaseService: Syncing/Updating product ${product.productId}');
        await ref.set(product.toMap(), SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      log('FirebaseService Error (syncProduct): ${e.code} - ${e.message}');
      throw _handleFirebaseError(e); // Rethrow a clean error for the BLoC/UI
    } catch (e) {
      log('FirebaseService Unexpected Error (syncProduct): $e');
      throw Exception('An unexpected error occurred while syncing your cart.');
    }
  }

  /// Fetches all products currently in the user's cart.
  Future<List<CartProductModel>> fetchCart() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        log('FirebaseService Error: Attempted to fetch cart without an authenticated user.');
        throw Exception('User is not authenticated.');
      }

      log('FirebaseService: Fetching cart for user ${currentUser.uid}');
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('cart')
          .get();

      return snapshot.docs
          .map((e) => CartProductModel.fromMap(e.data()))
          .toList();

    } on FirebaseException catch (e) {
      log('FirebaseService Error (fetchCart): ${e.code} - ${e.message}');
      throw _handleFirebaseError(e);
    } catch (e) {
      log('FirebaseService Unexpected Error (fetchCart): $e');
      throw Exception('Failed to load cart items.');
    }
  }

  String _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to access this data.';
      case 'unavailable':
        return 'The service is currently unavailable. Please check your internet.';
      case 'not-found':
        return 'The requested document was not found.';
      default:
        return e.message ?? 'A database error occurred.';
    }
  }
}