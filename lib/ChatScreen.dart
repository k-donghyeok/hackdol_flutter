import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map> _messages = [];

  void _sendMessage() async {
    if (_controller.text.isEmpty) {
      return;
    }

    setState(() {
      _messages.insert(0, {"data": 1, "message": _controller.text});
    });

    var response = await http.post(
      Uri.parse('http://localhost:5005/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"message": _controller.text}),
    );

    var data = json.decode(response.body);

    setState(() {
      _messages.insert(0, {
        "data": 0,
        "message": data['response'],
      });
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BlenderBot Chatbot"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          Divider(height: 1.0),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildMessage(Map message) {
    return ListTile(
      title: Align(
        alignment: message["data"] == 1 ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: message["data"] == 1 ? Colors.blueAccent : Colors.grey[200],
          ),
          padding: EdgeInsets.all(10.0),
          child: Text(
            message["message"],
            style: TextStyle(color: message["data"] == 1 ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _controller,
                onSubmitted: (value) => _sendMessage(),
                decoration: InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
