import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlockPhoneNumber {
  static const platform = MethodChannel('com.yourapp/block_call');
  static User? _user;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> _getCurrentUser() async {

    if (_auth.currentUser != null) {
      _user = _auth.currentUser;
    }
  }

  static Future<void> loadBlockedNumbers() async {
    _getCurrentUser();
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        List<dynamic> blockedNumbers = userDoc.get('blockedNumbers') ?? [];
        print("Blocked numbers loaded: $blockedNumbers"); // 로그로 출력
        await platform.invokeMethod('updateBlockedNumbers', blockedNumbers.cast<String>());
      }
    } catch (e) {
      print('Error loading blocked numbers: $e');
    }
  }
}
