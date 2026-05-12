import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/screens/home_screen.dart';
import '../../admin/screens/admin_screen.dart';
import '../screens/mobile_input_screen.dart';
import '../screens/otp_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String _tempMobile = '';
  String _tempPassword = '';
  String _tempName = '';
  bool _isNewUser = false;
  String _existingUid = '';

  static const String _staticOtp = '123456';
  static const String _adminMobile = '0000000000';
  static const String _adminPassword = 'admin123';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ── REGISTRATION ─────────────────────────────────────────
  Future<void> sendOtpForRegister(
      String mobile, String password, String name) async {
    if (mobile.length != 10) {
      errorMessage.value = 'Enter valid 10-digit number';
      return;
    }
    if (password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
      return;
    }
    if (name.trim().isEmpty) {
      errorMessage.value = 'Enter your name';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final query = await _firestore
          .collection('users')
          .where('mobile', isEqualTo: mobile)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        errorMessage.value = 'Account already exists. Please login.';
        isLoading.value = false;
        return;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      isLoading.value = false;
      return;
    }

    _tempMobile = mobile;
    _tempPassword = password;
    _tempName = name.trim();
    _isNewUser = true;
    _existingUid = '';
    isLoading.value = false;

    Get.to(() => OtpScreen(mobile: mobile));
  }

  // ── LOGIN ─────────────────────────────────────────────────
  Future<void> sendOtpForLogin(String mobile, String password) async {
    // Admin check
    if (mobile == _adminMobile && password == _adminPassword) {
      isLoading.value = true;
      errorMessage.value = '';
      try {
        await _auth.signInAnonymously();
        isLoading.value = false;
        Get.offAll(() => const AdminScreen());
      } catch (e) {
        errorMessage.value = 'Admin login failed: $e';
        isLoading.value = false;
      }
      return;
    }

    if (mobile.length != 10) {
      errorMessage.value = 'Enter valid 10-digit number';
      return;
    }
    if (password.isEmpty) {
      errorMessage.value = 'Enter your password';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final query = await _firestore
          .collection('users')
          .where('mobile', isEqualTo: mobile)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        errorMessage.value = 'No account found. Please register first.';
        isLoading.value = false;
        return;
      }

      final userData = query.docs.first.data();
      final storedHash = userData['passwordHash'] ?? '';
      final enteredHash = _hashPassword(password);

      if (storedHash != enteredHash) {
        errorMessage.value = 'Incorrect password';
        isLoading.value = false;
        return;
      }

      _tempMobile = mobile;
      _tempPassword = password;
      _isNewUser = false;
      _existingUid = query.docs.first.id;
      isLoading.value = false;

      Get.to(() => OtpScreen(mobile: mobile));
    } catch (e) {
      errorMessage.value = 'Error: $e';
      isLoading.value = false;
    }
  }

  // ── VERIFY STATIC OTP ─────────────────────────────────────
  Future<void> verifyOtp(String otp) async {
    if (otp.length != 6) {
      errorMessage.value = 'Enter 6-digit OTP';
      return;
    }

    if (otp != _staticOtp) {
      errorMessage.value = 'Invalid OTP. Use: $_staticOtp';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _auth.signOut();
      final cred = await _auth.signInAnonymously();
      final uid = cred.user!.uid;

      if (_isNewUser) {
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'mobile': _tempMobile,
          'name': _tempName,
          'passwordHash': _hashPassword(_tempPassword),
          'createdAt': DateTime.now(),
        });
      } else {
        if (uid != _existingUid) {
          final oldDoc = await _firestore
              .collection('users')
              .doc(_existingUid)
              .get();

          if (oldDoc.exists) {
            final data = oldDoc.data()!;
            await _firestore.collection('users').doc(uid).set({
              ...data,
              'uid': uid,
            });
            await _migrateSosEvents(_existingUid, uid);
            await _migrateIncidents(_existingUid, uid);
            _existingUid = uid;
          }
        }
      }

      isLoading.value = false;
      Get.offAll(() => const HomeScreen());
    } catch (e) {
      errorMessage.value = 'Sign in failed: $e';
      isLoading.value = false;
    }
  }

  Future<void> _migrateSosEvents(String oldUid, String newUid) async {
    try {
      final snap = await _firestore
          .collection('sos_events')
          .where('uid', isEqualTo: oldUid)
          .get();

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        final newRef = _firestore.collection('sos_events').doc();
        batch.set(newRef, {...doc.data(), 'uid': newUid});
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {}
  }

  Future<void> _migrateIncidents(String oldUid, String newUid) async {
    try {
      final snap = await _firestore
          .collection('incidents')
          .where('uid', isEqualTo: oldUid)
          .get();

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        final newRef = _firestore.collection('incidents').doc();
        batch.set(newRef, {...doc.data(), 'uid': newUid});
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {}
  }

  // ── LOGOUT ────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    Get.offAll(() => const MobileInputScreen());
  }
}