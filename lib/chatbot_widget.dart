import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotWidget extends StatefulWidget {
  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  final TextEditingController _controller = TextEditingController();
  String _response = "";

  Future<void> _sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/chatbot'),  // 서버 URL 변경 필요
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'question': message,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _response = jsonDecode(response.body)['response'];
      });
    } else {
      setState(() {
        _response = "Failed to get response from the server.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: InputDecoration(labelText: 'Enter your message'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _sendMessage(_controller.text);
          },
          child: Text('Send'),
        ),
        SizedBox(height: 20),
        Text(_response),
      ],
    );
  }
}
