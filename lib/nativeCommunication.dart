import 'package:flutter/services.dart';

class NativeCommunication {
  static const platform = MethodChannel('com.example.hackdol1_1/block_call');

  static Future<void> updateBlockedNumbers(List<String> numbers) async {
    try {
      await platform.invokeMethod('updateBlockedNumbers', numbers);
    } on PlatformException catch (e) {
      print("Failed to update blocked numbers: ${e.message}");
    }
  }
}
