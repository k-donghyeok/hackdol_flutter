import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Chat_message.dart';

class ChatBotWidget extends StatefulWidget {
  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.insert(0, ChatMessage(message: message, isUser: true));
    });
    _controller.clear();

    final response = await http.post(
      Uri.parse('http://192.168.35.3:5000/chatbot'),  // 서버 URL 변경 필요
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'question': message,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _messages.insert(0, ChatMessage(message: jsonDecode(response.body)['response'], isUser: false));
      });
    } else {
      setState(() {
        _messages.insert(0, ChatMessage(message: "Failed to get response from the server.", isUser: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: EdgeInsets.all(8.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return _buildMessage(message);
            },
          ),
        ),
        Divider(height: 1.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration.collapsed(hintText: 'Enter your message'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    _sendMessage(_controller.text);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final alignment = message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isUser ? Colors.blueAccent : Colors.grey.shade200;
    final textColor = message.isUser ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              message.message,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
