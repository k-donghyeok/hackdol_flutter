import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'myfirebase.dart';
import 'nativeCommunication.dart'; // FirebaseService 클래스 추가

class BlockTextPage extends StatefulWidget {
  @override
  _BlockTextPageState createState() => _BlockTextPageState();
}

class _BlockTextPageState extends State<BlockTextPage> {
  final FirebaseService _firebaseService = FirebaseService(); // FirebaseService 인스턴스 생성
  TextEditingController _textController = TextEditingController();
  List<String> _blockedTexts = [];

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      List<String> blockedTexts = await _firebaseService.loadBlockedTexts();
      setState(() {
        _blockedTexts = blockedTexts;
      });
      NativeCommunication.updateBlockedTexts(_blockedTexts);
    } catch (e) {
      print('Error loading blocked texts: $e');
    }
  }

  Future<void> _blockText(String text) async {
    if (_blockedTexts.contains(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$text is already blocked.')),
      );
      return;
    }

    try {
      await _firebaseService.blockText(text);
      setState(() {
        _blockedTexts.add(text);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$text has been blocked.')),
      );
      NativeCommunication.updateBlockedTexts(_blockedTexts);
    } catch (error) {
      print('Error blocking text: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to block text.')),
      );
    }
  }

  Future<void> _removeBlockedText(int index) async {
    String text = _blockedTexts[index];
    try {
      await _firebaseService.removeBlockedText(text);
      setState(() {
        _blockedTexts.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$text has been unblocked.')),
      );
      NativeCommunication.updateBlockedTexts(_blockedTexts);
    } catch (error) {
      print('Error unblocking text: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unblock text.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문구 차단'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: '문구',
                hintText: '문구를 입력해주세요',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String text = _textController.text;
                _blockText(text);
              },
              child: Text('문구 차단하기'),
            ),
            SizedBox(height: 20),
            Text(
              '차단된 문구 목록',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '옆으로 밀어서 삭제',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _blockedTexts.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_blockedTexts[index]),
                    background: Container(
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      await _removeBlockedText(index);
                    },
                    child: ListTile(
                      title: Text(_blockedTexts[index]),
                      leading: Icon(Icons.block),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Block Text',
    home: BlockTextPage(),
  ));
}
