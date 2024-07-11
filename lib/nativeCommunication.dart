import 'package:flutter/services.dart';

class NativeCommunication {
  static const platform = MethodChannel('com.example.hackdol1_1/block_call');
  static const textChannel = MethodChannel('com.example.hackdol1_1/block_text');

  static Future<void> updateBlockedNumbers(List<String> numbers) async {
    try {
      await platform.invokeMethod('updateBlockedNumbers', numbers);
    } on PlatformException catch (e) {
      print("Failed to update blocked numbers: ${e.message}");
    }
  }

  static Future<void> updateBlockedTexts(List<String> texts) async {
    try {
      await textChannel.invokeMethod('updateBlockedTexts', texts);
    } on PlatformException catch (e) {
      print("Failed to update blocked texts: ${e.message}");
    }
  }
}
