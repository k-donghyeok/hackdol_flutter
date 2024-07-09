import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'myfirebase.dart';
import 'nativeCommunication.dart'; // FirebaseService 클래스 추가

class BlockPhoneNumberPage extends StatefulWidget {
  @override
  _BlockPhoneNumberPageState createState() => _BlockPhoneNumberPageState();
}

class _BlockPhoneNumberPageState extends State<BlockPhoneNumberPage> {
  final FirebaseService _firebaseService = FirebaseService(); // FirebaseService 인스턴스 생성
  TextEditingController _phoneNumberController = TextEditingController();
  List<String> _blockedNumbers = [];

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      List<String> blockedNumbers = await _firebaseService.loadBlockedNumbers();
      setState(() {
        _blockedNumbers = blockedNumbers;
      });
      NativeCommunication.updateBlockedNumbers(_blockedNumbers);
    } catch (e) {
      print('Error loading blocked numbers: $e');
    }
  }

  Future<void> _blockPhoneNumber(String phoneNumber) async {
    if (_blockedNumbers.contains(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$phoneNumber is already blocked.')),
      );
      return;
    }

    try {
      await _firebaseService.blockPhoneNumber(phoneNumber);
      setState(() {
        _blockedNumbers.add(phoneNumber);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$phoneNumber has been blocked.')),
      );
      NativeCommunication.updateBlockedNumbers(_blockedNumbers);
    } catch (error) {
      print('Error blocking phone number: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to block phone number.')),
      );
    }
  }

  Future<void> _removeBlockedPhoneNumber(int index) async {
    String phoneNumber = _blockedNumbers[index];
    try {
      await _firebaseService.removeBlockedPhoneNumber(phoneNumber);
      setState(() {
        _blockedNumbers.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$phoneNumber has been unblocked.')),
      );
      NativeCommunication.updateBlockedNumbers(_blockedNumbers);
    } catch (error) {
      print('Error unblocking phone number: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unblock phone number.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('번호 차단'),
        centerTitle: true,
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
                String phoneNumber =_phoneNumberController.text;
                _blockPhoneNumber(phoneNumber);
              },
              child: Text('전화번호 차단하기'),
            ),
            SizedBox(height: 20),
            Text(
              '차단된 전화번호 목록',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '옆으로 밀어서 삭제',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _blockedNumbers.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_blockedNumbers[index]),
                    background: Container(
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      await _removeBlockedPhoneNumber(index);
                    },
                    child: ListTile(
                      title: Text(_blockedNumbers[index]),
                      leading: Icon(Icons.block),
                    ),
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
