import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/signup_model.dart';
import '../models/user_model.dart';

class AuthResult {
  final bool success;
  final String message;

  const AuthResult({
    required this.success,
    required this.message,
  });
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _initAuth();
  }

  // Getters
  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --------------------------------------------------
  // Initialize Firebase Auth and restore session
  // --------------------------------------------------
  void _initAuth() {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      _user = UserModel(
        id: currentUser.uid,
        name: currentUser.displayName?.isNotEmpty == true
            ? currentUser.displayName!
            : (currentUser.email?.split('@').first ?? 'User'),
        email: currentUser.email ?? '',
      );

      _isLoggedIn = true;
      _fetchUserProfile(currentUser.uid);
    }

    _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        _user = null;
        _isLoggedIn = false;
        notifyListeners();
      }
    });
  }

  // --------------------------------------------------
  // Save or update user profile in Firestore
  // --------------------------------------------------
  Future<void> _saveUserProfile({
    required User firebaseUser,
    String? name,
    bool isNewUser = false,
  }) async {
    final userRef =
        _firestore.collection('users').doc(firebaseUser.uid);

    // Read existing profile to preserve existing values.
    final existingDoc = await userRef.get();
    final existingData = existingDoc.data() ?? {};

    final data = <String, dynamic>{
      'id': firebaseUser.uid,
      'uid': firebaseUser.uid,
      'email': firebaseUser.email ?? '',
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    final cleanName = name?.trim();
    if (cleanName != null && cleanName.isNotEmpty) {
      data['name'] = cleanName;
    } else if (!existingDoc.exists) {
      data['name'] = firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          'User';
    }

    if (isNewUser || !existingDoc.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    } else if (existingData.containsKey('createdAt')) {
      // Keep the original createdAt value unchanged.
    }

    await userRef.set(data, SetOptions(merge: true));

    debugPrint(
      'FIRESTORE: Profile saved for UID ${firebaseUser.uid}',
    );
  }

  // --------------------------------------------------
  // Fetch user profile from Firestore
  // --------------------------------------------------
  Future<void> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        _user = UserModel(
          id: uid,
          name: data['name'] ?? _user?.name ?? 'User',
          email: data['email'] ?? _user?.email ?? '',
          phone: data['phone'],
          city: data['city'],
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Firestore fetch profile warning: $e');
    }
  }

  // --------------------------------------------------
  // Sign Up
  // --------------------------------------------------
  Future<AuthResult> signUp(SignUpModel signUpData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final email = signUpData.email.trim();
      final password = signUpData.password;

      debugPrint('SIGNUP: Firebase request started');

      final userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .timeout(const Duration(seconds: 25));

      debugPrint('SIGNUP: Firebase request completed');

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'unknown',
          message: 'Failed to create user account.',
        );
      }

      // Update Firebase Authentication display name.
      try {
        await firebaseUser.updateDisplayName(
          signUpData.name.trim(),
        );
      } catch (e) {
        debugPrint('Display name update warning: $e');
      }

      // Save profile to Firestore.
      try {
        await _saveUserProfile(
          firebaseUser: firebaseUser,
          name: signUpData.name,
          isNewUser: true,
        );
      } catch (e) {
        debugPrint('SIGNUP FIRESTORE ERROR: $e');

        _isLoading = false;
        _errorMessage =
            'Account created, but profile could not be saved. '
            'Please check Firestore rules and internet connection.';

        notifyListeners();

        // The Authentication account already exists.
        return AuthResult(
          success: true,
          message: _errorMessage!,
        );
      }

      _user = UserModel(
        id: firebaseUser.uid,
        name: signUpData.name.trim(),
        email: email,
        phone: signUpData.phone,
        city: signUpData.city,
      );

      _isLoggedIn = true;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      return const AuthResult(
        success: true,
        message: 'Account created and profile saved successfully.',
      );
    } on TimeoutException catch (e) {
      debugPrint('SIGNUP TIMEOUT: $e');

      _isLoading = false;
      _errorMessage =
          'Signup request timed out. Please check your internet connection.';
      notifyListeners();

      return AuthResult(
        success: false,
        message: _errorMessage!,
      );
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapFirebaseAuthError(e);
      notifyListeners();

      return AuthResult(
        success: false,
        message: _errorMessage!,
      );
    } catch (e) {
      debugPrint('SIGNUP ERROR: $e');

      _isLoading = false;
      _errorMessage = 'Sign up failed: $e';
      notifyListeners();

      return AuthResult(
        success: false,
        message: _errorMessage!,
      );
    }
  }

  // --------------------------------------------------
  // Login
  // --------------------------------------------------
  Future<AuthResult> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim();

      final userCredential = await _auth
          .signInWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          )
          .timeout(const Duration(seconds: 25));

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No account found.',
        );
      }

      // Fetch existing profile, if any.
      String name = firebaseUser.displayName ?? '';
      String? city;
      String? phone;

      try {
        final doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          name = data['name'] ?? name;
          city = data['city'];
          phone = data['phone'];
        }

        if (name.isEmpty) {
          name = firebaseUser.email?.split('@').first ?? 'User';
        }

        // Save missing profile or update lastLoginAt.
        await _saveUserProfile(
          firebaseUser: firebaseUser,
          name: name,
        );
      } catch (e) {
        // Authentication succeeded even if Firestore failed.
        debugPrint('LOGIN FIRESTORE ERROR: $e');
      }

      if (name.isEmpty) {
        name = firebaseUser.email?.split('@').first ?? 'User';
      }

      _user = UserModel(
        id: firebaseUser.uid,
        name: name,
        email: firebaseUser.email ?? cleanEmail,
        city: city,
        phone: phone,
      );

      _isLoggedIn = true;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      return AuthResult(
        success: true,
        message: 'Welcome back, ${_user!.name}!',
      );
    } on TimeoutException catch (e) {
      debugPrint('LOGIN TIMEOUT: $e');

      _isLoading = false;
      _errorMessage =
          'Login request timed out. Please check your internet connection.';
      notifyListeners();

      return AuthResult(
        success: false,
        message: _errorMessage!,
      );
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapFirebaseAuthError(e);
      notifyListeners();

      return AuthResult(
        success: false,
        message: _errorMessage!,
      );
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');

      _isLoading = false;
      _errorMessage = 'Login failed: $e';
      notifyListeners();

      return AuthResult(
        success: false,
        message: _errorMessage!,
      );
    }
  }

  // --------------------------------------------------
  // Password Reset
  // --------------------------------------------------
  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      return const AuthResult(
        success: true,
        message: 'Password reset link sent. Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _mapFirebaseAuthError(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to send reset link: $e',
      );
    }
  }

  // --------------------------------------------------
  // Logout
  // --------------------------------------------------
  void logout() {
    _auth.signOut().catchError((e) {
      debugPrint('Logout error: $e');
    });

    _user = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }

  // --------------------------------------------------
  // Map Firebase Authentication errors
  // --------------------------------------------------
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in.';

      case 'invalid-email':
        return 'The email address is invalid. Please check the format.';

      case 'operation-not-allowed':
        return 'Email/password sign-in is disabled in Firebase Console.';

      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';

      case 'user-disabled':
        return 'This user account has been disabled.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
        return 'Incorrect password. Please try again.';

      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';

      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      default:
        return e.message ?? 'An authentication error occurred. Please try again.';
    }
  }
}
