import 'package:flutter/services.dart';

class NativeCommunication {
  static const MethodChannel _channel = MethodChannel('com.yourapp/block_call');

  static Future<void> updateBlockedNumbers(List<String> blockedNumbers) async {
    try {
      await _channel.invokeMethod('updateBlockedNumbers', blockedNumbers);
      print("네이티브 쪽으로 차단된 번호 전달: $blockedNumbers");
    } on PlatformException catch (e) {
      print("네이티브 쪽으로 데이터 전달 실패: '${e.message}'.");
    }
  }
}
