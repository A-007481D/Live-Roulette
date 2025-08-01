import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  AppUser? _appUser;
  bool _isLoading = true;

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      _appUser = await FirebaseService.getUser(user.uid);
    } else {
      _appUser = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    required DateTime dateOfBirth,
  }) async {
    try {
      // Verify user is 18+
      final now = DateTime.now();
      final age = now.year - dateOfBirth.year;
      if (age < 18) {
        return 'You must be 18 or older to use Chaos Dare';
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final appUser = AppUser(
          id: credential.user!.uid,
          email: email,
          username: username,
          dateOfBirth: dateOfBirth,
          createdAt: DateTime.now(),
        );

        await FirebaseService.createUser(appUser);
        _appUser = appUser;
        notifyListeners();
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_user != null && _appUser != null) {
      await FirebaseService.updateUser(_user!.uid, data);
      _appUser = await FirebaseService.getUser(_user!.uid);
      notifyListeners();
    }
  }
}