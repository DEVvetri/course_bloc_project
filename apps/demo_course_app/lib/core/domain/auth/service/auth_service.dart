
import 'package:demo_course_app/core/data/auth/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // stream for auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // sign up
  Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;

    if (user != null) {
      // ✅ create default user model
      final userModel = UserModel(
        userId: user.uid,
        name: '',
        email: user.email ?? '',
        cartProductIds: [],
        address: '',
      );

      // ✅ save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());
    }

    return user;
  }

  // login
  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}