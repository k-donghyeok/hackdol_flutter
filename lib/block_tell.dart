import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlockPhoneNumberPage extends StatefulWidget {
  @override
  _BlockPhoneNumberPageState createState() => _BlockPhoneNumberPageState();
}

class _BlockPhoneNumberPageState extends State<BlockPhoneNumberPage> {
  static const platform = MethodChannel('com.example.block_phone_number');

  TextEditingController _phoneNumberController = TextEditingController();
  List<String> _blockedNumbers = [];

  @override
  void initState() {
    super.initState();
    // 이미 차단된 전화번호들을 가져와서 리스트에 추가합니다.
    _loadBlockedNumbers();
  }

  // 이미 차단된 전화번호들을 가져와서 리스트에 추가하는 메서드
  Future<void> _loadBlockedNumbers() async {
    try {
      List<dynamic> blockedNumbers =
      await platform.invokeMethod('getBlockedNumbers');
      setState(() {
        _blockedNumbers = blockedNumbers.cast<String>();
      });
    } on PlatformException catch (e) {
      print('Error loading blocked numbers: ${e.message}');
    }
  }

  Future<void> _callNativeCode(String phoneNumber) async {
    try {
      await platform.invokeMethod('blockPhoneNumber', {'phoneNumber': phoneNumber});
      print('전화번호가 차단되었습니다: $phoneNumber');
      // 차단된 전화번호를 리스트에 추가합니다.
      setState(() {
        _blockedNumbers.add(phoneNumber);
      });
    } on PlatformException catch (e) {
      print('전화번호 차단 중 오류 발생: ${e.message}');
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
                hintText: '전화번호를 입력하세요',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String phoneNumber = _phoneNumberController.text;
                _callNativeCode(phoneNumber);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$phoneNumber를 차단했습니다.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('전화번호 차단'),
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
    title: '전화번호 차단',
    home: BlockPhoneNumberPage(),
  ));
}
