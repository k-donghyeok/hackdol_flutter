import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hackdol1_1/block_tell.dart';
import 'FreeBoardPage.dart';
import 'myfirebase.dart';
import 'nativeCommunication.dart';
import 'RePortNumber.dart'; // report_number_screen.dart 파일을 임포트합니다.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _initializePage();
    _fetchSpamReports();
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

class SpamReportDetailScreen extends StatelessWidget {
  final String phoneNumber;

  const SpamReportDetailScreen({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('신고 내역'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('detailed_reports')
            .where('number', isEqualTo: phoneNumber)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var document = documents[index];
              return ListTile(
                title: Text('제목: ${document['title']}'),
                subtitle: Text('글쓴이: ${document['author']}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('신고 내역'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('신고 번호: ${document['number']}'),
                            SizedBox(height: 8),
                            Text('제목: ${document['title']}'),
                            SizedBox(height: 8),
                            Text('신고 사유: ${document['reason']}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('닫기'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
