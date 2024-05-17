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
          List<dynamic> blockedNumbersList =
              userDoc.get('blockedNumbers') ?? [];
          blockedNumbers = blockedNumbersList.cast<String>();
          print(blockedNumbers);
        }
      } catch (e) {
        print('Error loading blocked numbers: $e');
      }
    }

    return blockedNumbers;
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
}
