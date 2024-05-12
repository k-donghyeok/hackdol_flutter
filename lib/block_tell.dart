import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlockPhoneNumberPage extends StatefulWidget {
  @override
  _BlockPhoneNumberPageState createState() => _BlockPhoneNumberPageState();
}

class _BlockPhoneNumberPageState extends State<BlockPhoneNumberPage> {
  TextEditingController _phoneNumberController = TextEditingController();

  // 네이티브 코드를 호출하여 전화번호를 전달하는 메서드
  Future<void> _callNativeCode(String phoneNumber) async {
    const platform = MethodChannel('com.example.myplugin/my_channel');
    try {
      // 네이티브 코드의 메서드를 호출하고 전화번호를 전달합니다.
      await platform.invokeMethod('blockPhoneNumber', phoneNumber);
      print('Phone number blocked: $phoneNumber');
    } on PlatformException catch (e) {
      // 오류 처리
      print('Error blocking phone number: ${e.message}');
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
