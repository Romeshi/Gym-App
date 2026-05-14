import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GymProvider extends ChangeNotifier {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local State
  String? _currentGymId;
  String? _currentGymName;
  String? _currentLocation;
  String? _ownerName;
  String? _ownerEmail;
  String? _verificationId;

  // Getters
  String? get currentGymId => _currentGymId;
  String? get currentGymName => _currentGymName;
  String? get currentLocation => _currentLocation;
  String? get ownerName => _ownerName;
  String? get verificationId => _verificationId;

  // --- 1. REGISTRATION LOGIC WITH EMAIL VERIFICATION ---
  Future<bool> registerNewGym({
    required String id,
    required String gymName,
    required String location,
    required String ownerName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.sendEmailVerification();

      await _firestore.collection('gyms').doc(userCredential.user!.uid).set({
        'gymId': id,
        'ownerUid': userCredential.user!.uid,
        'gymName': gymName,
        'location': location,
        'ownerName': ownerName,
        'email': email,
        'phoneNumber': phoneNumber,
        'mfaEnabled': true,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _currentGymId = id;
      _currentGymName = gymName;
      _currentLocation = location;
      _ownerName = ownerName;
      _ownerEmail = email;

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("Auth Error: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Firestore Error: $e");
      return false;
    }
  }

  // --- 2. RESEND VERIFICATION EMAIL ---
  Future<void> resendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint("Verification email resent.");
      }
    } catch (e) {
      debugPrint("Error resending email: $e");
      rethrow;
    }
  }

  // --- 3. SECURE LOGIN LOGIC (WITH CACHE FIX) ---
  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.reload();
        user = _auth.currentUser;

        if (!user!.emailVerified) {
          return "EMAIL_NOT_VERIFIED";
        }

        DocumentSnapshot doc = await _firestore
            .collection('gyms')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          if (data['phoneNumber'] != null) {
            String? vId = await trigger2FA(data['phoneNumber']);
            return vId;
          }
        }

        await _loadGymData(user.uid);
        return null;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("Login Failed: ${e.code}");
      rethrow;
    }
  }

  // --- 4. 2-STEP VERIFICATION (SMS) WITH BILLING CHECK ---
  Future<String?> trigger2FA(String phoneNumber) async {
    Completer<String?> completer = Completer();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.currentUser!.linkWithCredential(credential);
        await _loadGymData(_auth.currentUser!.uid);
        if (!completer.isCompleted) completer.complete(null);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("Phone verification failed: ${e.message} [ ${e.code} ]");

        if (e.code == 'billing-not-enabled' ||
            e.message?.contains('BILLING_NOT_ENABLED') == true) {
          debugPrint(
            "CRITICAL: Firebase Blaze plan required for live SMS in this region.",
          );
          completer.completeError(
            "SMS service is in test-mode. Please use a registered test number.",
          );
        } else {
          completer.completeError(e);
        }
      },
      codeSent: (String vId, int? resendToken) {
        _verificationId = vId;
        notifyListeners();
        if (!completer.isCompleted) completer.complete(vId);
      },
      codeAutoRetrievalTimeout: (String vId) {
        _verificationId = vId;
        if (!completer.isCompleted) completer.complete(vId);
      },
    );
    return completer.future;
  }

  // --- 5. OTP VERIFICATION ---
  Future<bool> verifySmsCode(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
      await _loadGymData(_auth.currentUser!.uid);
      return true;
    } catch (e) {
      debugPrint("OTP Verification Failed: $e");
      return false;
    }
  }

  // --- 6. PASSWORD RESET LOGIC ---
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email sent to $email");
    } on FirebaseAuthException catch (e) {
      debugPrint("Reset Email Error: ${e.code}");
      rethrow;
    }
  }

  // --- 7. HELPERS ---
  Future<void> _loadGymData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('gyms').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _currentGymId = data['gymId'];
        _currentGymName = data['gymName'];
        _currentLocation = data['location'];
        _ownerName = data['ownerName'];
        _ownerEmail = data['email'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading gym data: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentGymId = null;
    _currentGymName = null;
    _currentLocation = null;
    _ownerName = null;
    _ownerEmail = null;
    _verificationId = null;
    notifyListeners();
  }
}
