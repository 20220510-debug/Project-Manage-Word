import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Đăng nhập
  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();

      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!, credential.user!.uid);
      } else {
        _currentUser = UserModel(
          uid: credential.user!.uid,
          name: "Người dùng",
          email: email,
          role: UserRole.staff,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(credential.user!.uid).set(_currentUser!.toMap());
      }

      notifyListeners();
      return _currentUser;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // Đăng ký
  Future<UserModel?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: credential.user!.uid,
        name: email.split('@')[0],
        email: email,
        role: UserRole.staff,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(credential.user!.uid).set(user.toMap());

      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      print("Register error: $e");
      return null;
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}