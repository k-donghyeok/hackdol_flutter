import 'package:flutter/material.dart';

class PopupScreen extends StatelessWidget {
  final String message;
  final String sender;
  final bool isSpam;
  final VoidCallback onBlock;

  const PopupScreen({
    Key? key,
    required this.message,
    required this.sender,
    required this.isSpam,
    required this.onBlock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('팝업 스크린 만드는중');
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isSpam ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Message from $sender',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 10),
              if (isSpam)
                ElevatedButton(
                  onPressed: onBlock,
                  child: Text('Block'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
