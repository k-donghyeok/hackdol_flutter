import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'myfirebase.dart';

class ReportNumberScreen extends StatefulWidget {
  @override
  _ReportNumberScreenState createState() => _ReportNumberScreenState();
}

class _ReportNumberScreenState extends State<ReportNumberScreen> {
  final _numberController = TextEditingController();
  final _titleController = TextEditingController();
  final _reasonController = TextEditingController();

  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _reportNumber() async {
    final number = _numberController.text;
    final title = _titleController.text;
    final reason = _reasonController.text;

    if (number.isNotEmpty && title.isNotEmpty && reason.isNotEmpty) {
      final user = _auth.currentUser;

      if (user != null) {
        final displayName = await _firebaseService.getUserName();

        final reportRef = FirebaseFirestore.instance.collection('reports').doc(number);

        FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(reportRef);

          if (!snapshot.exists) {
            transaction.set(reportRef, {
              'count': 1,
            });

            // detailed_reports 컬렉션에 추가
            FirebaseFirestore.instance.collection('detailed_reports').add({
              'title': title,
              'reason': reason,
              'number': number,
              'author': displayName,
              'timestamp': FieldValue.serverTimestamp(),
            });
          } else {
            transaction.update(reportRef, {
              'count': snapshot.get('count') + 1,
            });

            // detailed_reports 컬렉션에 추가
            FirebaseFirestore.instance.collection('detailed_reports').add({
              'title': title,
              'reason': reason,
              'number': number,
              'author': displayName,
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        });

        _numberController.clear();
        _titleController.clear();
        _reasonController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('신고가 접수되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인이 필요합니다.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('번호 신고'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _numberController,
              decoration: InputDecoration(labelText: '신고할 번호'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(labelText: '신고 사유'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _reportNumber,
              child: Text('신고하기'),
            ),
          ],
        ),
      ),
    );
  }
}
