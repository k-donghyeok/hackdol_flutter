import 'package:flutter/material.dart';
import 'chatbot_widget.dart';  // 챗봇 위젯 파일 import

class ChatBotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ChatBotWidget(),  // 챗봇 위젯 추가
      ),
    );
  }
}
