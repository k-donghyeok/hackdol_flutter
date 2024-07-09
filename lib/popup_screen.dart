// popup_screen.dart
import 'package:flutter/material.dart';

class PopupScreen extends StatelessWidget {
  final String message;
  final String sender;
  final bool isSpam;
  final Function onBlock;

  const PopupScreen({
    Key? key,
    required this.message,
    required this.sender,
    required this.isSpam,
    required this.onBlock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isSpam ? Colors.red : Colors.green,
      appBar: AppBar(
        title: Text('Message from $sender'),
        backgroundColor: isSpam ? Colors.red : Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 20),
            if (isSpam)
              ElevatedButton(
                onPressed: () {
                  onBlock();
                  Navigator.of(context).pop();
                },
                child: Text('Block'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Message List'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
