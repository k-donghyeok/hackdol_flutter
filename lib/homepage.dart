import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hackdol1_1/block_tell.dart';
import 'FreeBoardPage.dart';
import 'myfirebase.dart';
import 'nativeCommunication.dart';
import 'RePortNumber.dart'; // report_number_screen.dart 파일을 임포트합니다.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final postList = [
    {"rank": 1, "title": "010-6326-2371", "reportCount": 34},
    {"rank": 2, "title": "010-6326-2371", "reportCount": 32},
    {"rank": 3, "title": "010-6326-2371", "reportCount": 30},
    {"rank": 4, "title": "010-6326-2371", "reportCount": 28},
  ];

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    final FirebaseService _firebaseService = FirebaseService();

    try {
      List<String> blockedNumbers = await _firebaseService.loadBlockedNumbers();
      NativeCommunication.updateBlockedNumbers(blockedNumbers);
    } catch (e) {
      print('Error loading blocked numbers: $e');
    }
    print("MainScreen이 처음 실행되었습니다.");
  }

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
                    title: Text('번호 차단'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BlockPhoneNumberPage()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('문구 차단'),
                    onTap: () {
                      _launchURL('https://www.example.com'); // 예시 URL
                    },
                  ),
                  ListTile(
                    title: Text('차단된 메시지'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BlockPhoneNumberPage()),
                      );
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
                    title: Text('번호 신고'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReportNumberScreen()), // ReportNumberScreen으로 이동
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
                    onTap: () async {
                      Map<String, dynamic>? userInfo = await FirebaseUserService().getUserInfo();
                      if (userInfo != null) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('내 정보'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('이메일: ${userInfo!['email']}'),
                                    Text('성별: ${userInfo!['gender']}'),
                                    Text('이름: ${userInfo!['name']}'),
                                    Text('전화번호: ${userInfo!['phoneNumber']}'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('닫기'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // 사용자 정보를 가져오는데 실패한 경우에 대한 처리
                      }
                    },
                  ),
                  ListTile(
                    title: Text('로그아웃'),
                    onTap: () {
                      _showLogoutConfirmationDialog(context);
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
              DataColumn(label: Text('등수', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('전화번호', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('신고수', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: postList.map((data) => DataRow(
              cells: [
                DataCell(Text(data['rank'].toString())),
                DataCell(Text(data['title'].toString())),
                DataCell(Text(data['reportCount'].toString())),
              ],
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
      await launch(url, forceSafariVC: false); // forceSafariVC false로 설정
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('로그아웃'),
        content: Text('로그아웃 하시겠습니까?'),
        actions: <Widget>[
          SizedBox(
            width: 100, // 버튼 너비 조정
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 100, // 버튼 너비 조정
            child: TextButton(
              onPressed: () {
                _logoutAndNavigateToLogin(context);
              },
              child: Text(
                '로그아웃',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _logoutAndNavigateToLogin(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      print("Error logging out: $e");
    }
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

class FirebaseUserService {
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userInfo = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userInfo.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching user info: $e');
      return null;
    }
  }
}

class UserInfoPage extends StatelessWidget {
  final Map<String, dynamic>? userInfo;

  const UserInfoPage({Key? key, this.userInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userInfo != null) ...[
              Text('이메일: ${userInfo!['email']}'),
              Text('성별: ${userInfo!['gender']}'),
              Text('이름: ${userInfo!['name']}'),
              Text('전화번호: ${userInfo!['phoneNumber']}'),
            ] else ...[
              Text('사용자 정보를 불러올 수 없습니다.'),
            ],
          ],
        ),
      ),
    );
  }
}

class BlockPhoneNumberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('번호 차단'),
      ),
      body: Center(
        child: Text('번호 차단 페이지'),
      ),
    );
  }
}

class FreeBoardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자유게시판'),
      ),
      body: Center(
        child: Text('자유게시판 페이지'),
      ),
    );
  }
}

class ReportNumberScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('번호 신고'),
      ),
      body: Center(
        child: Text('번호 신고 페이지'),
      ),
    );
  }
}

