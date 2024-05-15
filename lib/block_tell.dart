import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlockPhoneNumberPage extends StatefulWidget {
  @override
  _BlockPhoneNumberPageState createState() => _BlockPhoneNumberPageState();
}

class _BlockPhoneNumberPageState extends State<BlockPhoneNumberPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const platform = MethodChannel('com.yourapp/block_call');

  User? _user;
  TextEditingController _phoneNumberController = TextEditingController();
  List<String> _blockedNumbers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _user = _auth.currentUser;
    if (_user != null) {
      _loadBlockedNumbers();
      _updateBlockedNumbersOnNative();
    }
  }

  Future<void> _loadBlockedNumbers() async {
    if (_user == null) return;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        List<dynamic> blockedNumbers = userDoc.get('blockedNumbers') ?? [];
        setState(() {
          _blockedNumbers = blockedNumbers.cast<String>();
        });
        _updateBlockedNumbersOnNative();
      }
    } catch (e) {
      print('Error loading blocked numbers: $e');
    }
  }

  Future<void> _blockPhoneNumber(String phoneNumber) async {
    if (_user == null) return;

    if (_blockedNumbers.contains(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$phoneNumber is already blocked.')),
      );
      return;
    }

    try {
      await _firestore.collection('users').doc(_user!.uid).set({
        'blockedNumbers': FieldValue.arrayUnion([phoneNumber])
      }, SetOptions(merge: true));

      setState(() {
        _blockedNumbers.add(phoneNumber);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$phoneNumber has been blocked.')),
      );

      _updateBlockedNumbersOnNative();
    } catch (e) {
      print('Error blocking phone number: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to block phone number.')),
      );
    }
  }

  Future<void> _updateBlockedNumbersOnNative() async {
    try {
      await platform.invokeMethod('updateBlockedNumbers', _blockedNumbers);
    } on PlatformException catch (e) {
      print("Failed to update blocked numbers on native: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('전화번호 차단'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: '전화번호',
                hintText: '전화번호를 입력해주세요',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String phoneNumber = _phoneNumberController.text;
                _blockPhoneNumber(phoneNumber);
              },
              child: Text('전화번호 차단하기'),
            ),
            SizedBox(height: 20),
            Text(
              '차단된 전화번호 목록',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _blockedNumbers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_blockedNumbers[index]),
                    leading: Icon(Icons.block),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Block Phone Number',
    home: BlockPhoneNumberPage(),
  ));
}
