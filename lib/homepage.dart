import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 임포트 추가
import 'package:hackdol1_1/block_tell.dart';
import 'FreeBoardPage.dart';
import 'chatbot.dart';
import 'homepage.dart'; // homepage.dart 파일 임포트 추가


class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  MainScreen({Key? key}) : super(key: key);

  final postList = [
    {"rank": 1, "title": "010-6326-2371", "reportCount": 34},
    {"rank": 2, "title": "010-6326-2371", "reportCount": 32},
    {"rank": 3, "title": "010-6326-2371", "reportCount": 30},
    {"rank": 4, "title": "010-6326-2371", "reportCount": 28},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메인 화면'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ExpansionTile(
              title: Text('스팸'),
              children: [
                ListTile(
                  title: Text('차단 번호'),
                  onTap: () {
                    Navigator.push( // 네비게이션을 통해 다른 화면으로 이동
                      context,
                      MaterialPageRoute(
                          builder: (context) => BlockPhoneNumberPage()),
                    );
                  },
                ),
                ListTile(
                  title: Text('차단 문구'),
                  onTap: () {
                    _launchURL('https://www.example.com'); // 예시 URL
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: Text('커뮤니티'),
              children: [
                ListTile(
                  title: Text('자유게시판'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FreeBoardPage()),
                    );
                  },
                ),
                ListTile(
                  title: Text('Chatbot'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatBotPage()),
                    );
                  },
                ),

              ],
            ),
            ExpansionTile(
              title: Text('내 정보'),
              children: [
                ListTile(
                  title: Text('내 정보 확인'),
                  onTap: () {
                    _showUserInfoDialog(context); // 내 정보 확인 다이얼로그 표시
                  },
                ),
                ListTile(
                  title: Text('로그아웃'),
                  onTap: () {
                    _showLogoutDialog(context); // 로그아웃 다이얼로그 표시
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Center(
            child: Text(
              '실시간 스팸신고 랭킹',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: DataTable(
              columns: [
                DataColumn(label: Text(
                    '등수', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(
                    '전화번호', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(
                    '신고수', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: postList.map((data) =>
                  DataRow(
                      cells: [
                        DataCell(Text(data['rank'].toString())),
                        DataCell(Text(data['title'].toString())),
                        DataCell(Text(data['reportCount'].toString())),
                      ]
                  )).toList(),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyBannerWidget(
                  imageUrl: 'assets/image/police.png',
                  linkUrl: 'https://www.police.go.kr',
                  label: '경찰청 사이트로 이동',
                ),
                SizedBox(width: 50),
                MyBannerWidget(
                  imageUrl: 'assets/image/kisa.png',
                  linkUrl: 'https://spam.kisa.or.kr/spam/ss/ssSpamInfo.do?mi=1025',
                  label: 'KISA 사이트로 이동',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("로그아웃"),
          content: Text("로그아웃 하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text("취소"),
              style: TextButton.styleFrom(
                minimumSize: Size(40, 30), // 버튼 크기 조정
              ),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut(); // Firebase 로그아웃 처리
                Navigator.of(context).pushNamedAndRemoveUntil(
                    "/login", (route) => false); // 로그인 화면으로 이동하면서 이전 경로 스택 제거
              },
              child: Text("예"),
              style: TextButton.styleFrom(
                minimumSize: Size(40, 30), // 버튼 크기 조정
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUserInfoDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Firestore에서 사용자 정보 가져오기
      FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("내 정보 확인"),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data["name"] != null) _buildUserInfoRow("이름", data["name"]),
                    if (data["phone"] != null) _buildUserInfoRow("전화번호", data["phone"]),
                    if (data["email"] != null) _buildUserInfoRow("이메일", data["email"]),
                    if (data["gender"] != null) _buildUserInfoRow("성별", data["gender"]),
                    _buildUserInfoRow("비밀번호", "********"), // 보안 상 비밀번호는 별표로 표시
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                    },
                    child: Text("확인"),
                  ),
                ],
              );
            },
          );
        }
      });
    } else {
      // 현재 사용자가 null인 경우 처리할 코드 추가
    }
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value ?? ""), // null 체크 후 값을 출력하거나 빈 문자열 출력
        ],
      ),
    );
  }
}

class MyBannerWidget extends StatelessWidget {
  final String imageUrl;
  final String linkUrl;
  final String label;

  const MyBannerWidget({
    required this.imageUrl,
    required this.linkUrl,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchURL(linkUrl);
      },
      child: Column(
        children: [
          Image.asset(
            imageUrl,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false); // forceSafariVC false로 설정
    } else {
      throw 'Could not launch $url';
    }
  }
}
