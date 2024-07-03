import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:hackdol1_1/block_tell.dart';
import 'FreeBoardPage.dart';

import 'chat_screen.dart';
import 'myfirebase.dart';
import 'nativeCommunication.dart';
import 'RePortNumber.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'spam_report_detail_screen.dart';
import 'my_banner_widget.dart';
import 'dart:async';

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
  List<Map<String, dynamic>> postList = [];
  List<Map<String, dynamic>> newsList = [];
  PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializePage();
    _fetchSpamReports();
    _fetchNews();

    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (_currentPage < newsList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 3600),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
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

  Future<void> _fetchSpamReports() async {
    FirebaseFirestore.instance.collection('reports').snapshots().listen((snapshot) {
      List<Map<String, dynamic>> tempList = [];
      snapshot.docs.forEach((doc) {
        tempList.add({
          "title": doc.id,
          "reportCount": doc.data()['count'],
        });
      });
      tempList.sort((a, b) => b['reportCount'].compareTo(a['reportCount']));
      for (int i = 0; i < tempList.length; i++) {
        tempList[i]['rank'] = i + 1;
      }
      setState(() {
        postList = tempList.take(5).toList(); // 상위 5개 항목만 선택
      });
    });
  }

  Future<void> _fetchNews() async {
    final response = await http.get(Uri.parse('https://newsapi.org/v2/top-headlines?country=us&apiKey=2d48e97c9323495aada624bd870c61dc'));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      List<dynamic> articles = jsonData['articles'];
      List<Map<String, dynamic>> tempList = [];
      articles.forEach((article) {
        tempList.add({
          "imageUrl": article['urlToImage'] ?? '',
          "linkUrl": article['url'] ?? '',
          "label": article['title'] ?? ''
        });
      });
      setState(() {
        newsList = tempList;
      });
    } else {
      throw Exception('Failed to load news');
    }
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
                      MaterialPageRoute(
                          builder: (context) => ChatScreen()), // 챗봇 페이지로 이동
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
                    _showUserInfoDialog(context);
                  },
                ),
                ListTile(
                  title: Text('로그아웃'),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
            DataTable(
              columns: [
                DataColumn(label: Text('등수', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('전화번호', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('신고수', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: postList.map((data) => DataRow(
                cells: [
                  DataCell(Text(data['rank'].toString())),
                  DataCell(
                    Text(data['title'].toString()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpamReportDetailScreen(phoneNumber: data['title'].toString()),
                        ),
                      );
                    },
                  ),
                  DataCell(Text(data['reportCount'].toString())),
                ],
              )).toList(),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 200, // 배너의 높이를 지정합니다.
              child: PageView.builder(
                controller: _pageController,
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  final news = newsList[index];
                  return MyBannerWidget(
                    imageUrl: news['imageUrl'],
                    linkUrl: news['linkUrl'],
                    label: news['label'],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  GestureDetector(
                    onTap: () {
                      _launchURL('https://www.police.go.kr');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/image/police.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '경찰청 사이트로 이동',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchURL('https://spam.kisa.or.kr/spam/ss/ssSpamInfo.do?mi=1025');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/image/kisa.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'KISA 사이트로 이동',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  void _showUserInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _getUserInfo(),
          builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 데이터 로딩 중이면 로딩 스피너 표시
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // 에러가 발생하면 에러 메시지 표시
              return AlertDialog(
                title: Text("에러"),
                content: Text("사용자 정보를 가져오는 중에 오류가 발생했습니다."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("확인"),
                  ),
                ],
              );
            } else {
              // 데이터를 성공적으로 가져오면 사용자 정보 다이얼로그 표시
              final userInfo = snapshot.data!;
              return AlertDialog(
                title: Text("내 정보 확인"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfoRow('이메일', userInfo['email']),
                    _buildUserInfoRow('성별', userInfo['gender']),
                    _buildUserInfoRow('이름', userInfo['name']),
                    _buildUserInfoRow('전화번호', userInfo['phoneNumber']),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("확인"),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildUserInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    return userData.data() as Map<String, dynamic>;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("로그아웃"),
          content: Text("로그아웃 하시겠습니까?"),
          actions: <Widget>[
            SizedBox(
              width: 100,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("아니요"),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                },
                child: Text("예"),
              ),
            ),
          ],
        );
      },
    );
  }
}
