import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<List<String>> loadBlockedNumbers() async {
    User? user = _auth.currentUser;
    List<String> blockedNumbers = [];

    if (user != null) {
      try {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          List<dynamic> blockedNumbersList = userDoc.get('blockedNumbers') ?? [];
          blockedNumbers = blockedNumbersList.cast<String>();
          print(blockedNumbers);
        }
      } catch (e) {
        print('Error loading blocked numbers: $e');
      }
    }

    return blockedNumbers;
  }

  Future<String> getUserName() async {
    User? user = _auth.currentUser;
    String username = "";

    if (user != null) {
      try {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          username = userDoc.get('name');
        }
      } catch (e) {
        print('Error loading username: $e');
      }
    }

    return username;
  }

  Future<void> blockPhoneNumber(String phoneNumber) async {
    User? user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'blockedNumbers': FieldValue.arrayUnion([phoneNumber])
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error blocking phone number: $e');
      throw e;
    }
  }

  Future<void> removeBlockedPhoneNumber(String phoneNumber) async {
    User? user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'blockedNumbers': FieldValue.arrayRemove([phoneNumber])
      });
    } catch (e) {
      print('Error unblocking phone number: $e');
      throw e;
    }
  }

  // 문구 차단 기능 추가
  Future<List<String>> loadBlockedTexts() async {
    User? user = _auth.currentUser;
    List<String> blockedTexts = [];

    if (user != null) {
      try {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          List<dynamic> blockedTextsList = userDoc.get('blockedTexts') ?? [];
          blockedTexts = blockedTextsList.cast<String>();
          print(blockedTexts);
        }
      } catch (e) {
        print('Error loading blocked texts: $e');
      }
    }

    return blockedTexts;
  }

  Future<void> blockText(String text) async {
    User? user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'blockedTexts': FieldValue.arrayUnion([text])
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error blocking text: $e');
      throw e;
    }
  }

  Future<void> removeBlockedText(String text) async {
    User? user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'blockedTexts': FieldValue.arrayRemove([text])
      });
    } catch (e) {
      print('Error unblocking text: $e');
      throw e;
    }
  }
}
