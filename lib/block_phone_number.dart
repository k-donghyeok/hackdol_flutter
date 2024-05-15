import 'package:flutter/services.dart';

class BlockPhoneNumber {
  static const platform = MethodChannel('com.yourapp/block_call');

  static Future<void> loadBlockedNumbers() async {
    try {
      // 여기에 파이어스토어에서 blocknumbers 값을 가져오는 코드를 작성하세요
      List<String> blockedNumbers = ['01012345678', '01087654321']; // 예시 데이터
      await platform.invokeMethod('updateBlockedNumbers', blockedNumbers);
    } on PlatformException catch (e) {
      print("Failed to load blocked numbers: '${e.message}'.");
    }
  }
}
