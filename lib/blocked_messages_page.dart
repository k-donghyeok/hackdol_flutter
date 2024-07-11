import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // 날짜 형식 변환을 위한 패키지

class BlockedMessagesPage extends StatefulWidget {
  @override
  _BlockedMessagesPageState createState() => _BlockedMessagesPageState();
}

class _BlockedMessagesPageState extends State<BlockedMessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('차단된 메시지 목록'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('spamMessages').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('차단된 메시지가 없습니다.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              DateTime reportedAt = data['reportedAt'].toDate();
              String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(reportedAt);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '발신자: ${data['sender']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '메시지: ${data['message']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '차단된 일시: $formattedDate',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.redAccent,
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessageDetailPage(
                                sender: data['sender'],
                                message: data['message'],
                                reason: data['reason'] ?? '스팸 의심',
                                reportedAt: formattedDate,
                              ),
                            ),
                          );
                        },
                        child: Text('세부 정보 보기'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class MessageDetailPage extends StatelessWidget {
  final String sender;
  final String message;
  final String reason;
  final String reportedAt;

  MessageDetailPage({
    required this.sender,
    required this.message,
    required this.reason,
    required this.reportedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메시지 세부 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('발신자: $sender', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('메시지:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(message, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('차단된 이유: $reason', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('차단된 일시: $reportedAt', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
