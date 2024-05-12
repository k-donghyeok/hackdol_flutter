import 'package:flutter/material.dart';

class FreeBoardPage extends StatefulWidget {
  @override
  _FreeBoardPageState createState() => _FreeBoardPageState();
}

class _FreeBoardPageState extends State<FreeBoardPage> {
  List<Post> posts = []; // 게시글을 저장할 리스트

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자유게시판'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10), // 조금의 여백을 추가합니다.
            // 자유게시판 사용 방법 추가
            Text(
              '공지사항',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10), // 조금의 여백을 추가합니다.
            ElevatedButton(
              onPressed: () {
                _showUsageGuide(context); // 사용 방법을 표시하는 다이얼로그를 표시합니다.
              },
              child: Text('자유게시판 사용 방법'),
            ),
            SizedBox(height: 20), // 여백 추가

            // 저장된 게시글 제목들을 표시
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: posts.map((post) {
                return GestureDetector(
                  onTap: () {
                    _openPostDetailPage(context, post); // 게시글 상세 화면으로 이동합니다.
                  },
                  child: Text(post.title),
                );
              }).toList(),
            ),

            SizedBox(height: 20), // 여백 추가

            // 글쓰기 버튼
            Padding(
              padding: EdgeInsets.only(bottom: 20), // 아래쪽 여백 추가
              child: ElevatedButton(
                onPressed: () {
                  _openWritePostPage(context); // 글쓰기 페이지로 이동합니다.
                },
                child: Text('글쓰기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 사용 방법을 표시하는 다이얼로그를 표시하는 함수
  void _showUsageGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('클린한 자유게시판 사용 방법'),
          content: SingleChildScrollView(
            child: Text(
              '1. 게시글 작성 가이드라인\n\u23CF 욕설, 비방, 혐오 표현 등 부적절한 언어 사용을 삼가해 주시기 바랍니다.\n\u23CF 불법 콘텐츠 게시, 저작권 침해 등 법률에 반하는 행위는 엄격히 금지됩니다.'
                  '\n\u23CF 타인의 개인정보를 공개하거나 사생활을 침해하는 게시글은 삭제될 수 있습니다.\n\n '
                  '2. 관리자 연락처 \n\u23CF문의사항이나 건의사항이 있으시면 언제든지 관리자에게 연락 주시기 바랍니다.'
                  '\n\u23CF 이메일: shock159@naver.com \n\n '
                  '3. 게시판 목적 \n\u23CF자유게시판은 자유로운 의견 교환을 위한 공간으로, 다양한 주제에 대한 토론과 소통을 장려합니다. \n\u23CF허용되는 주제: 취미, 문화, 일상 이야기, 정보 공유 등 \n\n'
                  '4. 사용자 권리와 책임 \n\u23CF다른 사용자를 존중하고 예의를 갖추어 주시기 바랍니다. 모두가 쾌적한 환경에서 소통할 수 있어야 합니다. \n\u23CF개인정보 보호에 유의하여 주시기 바랍니다. 개인정보를 공유하는 행위는 개인의 책임 아래 이루어져야 합니다.\n\n'
                  '5.커뮤니티 규칙 및 제재 \n\u23CF위 조항을 준수하지 않는 경우, 관리자는 게시물을 삭제하거나 사용자에게 경고를 발송할 수 있습니다. \n\u23CF반복적으로 규칙을 어기거나 심각한 위반 행위를 한 경우, 사용자의 계정에 대한 제재가 가해질 수 있습니다.',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그를 닫습니다.
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  // 글쓰기 페이지로 이동하는 함수
  void _openWritePostPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritePostPage(), // 글쓰기 페이지로 이동합니다.
      ),
    );

    if (result != null) {
      setState(() {
        posts.add(result); // 작성한 게시글을 리스트에 추가합니다.
      });
    }
  }

  // 게시글 상세 화면으로 이동하는 함수
  void _openPostDetailPage(BuildContext context, Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(post), // 게시글 상세 화면으로 이동합니다.
      ),
    );
  }
}

// 글쓰기 페이지 위젯
class WritePostPage extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 작성'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 제목 입력 필드
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
              ),
            ),
            SizedBox(height: 10), // 조금의 여백을 추가합니다.
            // 내용 입력 필드
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
              ),
              maxLines: 5, // 여러 줄 입력 가능하도록 설정합니다.
            ),
            SizedBox(height: 20), // 여백 추가
            // 게시 버튼
            ElevatedButton(
              onPressed: () {
                // 작성한 글을 저장하고 글쓰기 페이지를 닫습니다.
                Navigator.pop(
                  context,
                  Post(
                    _titleController.text,
                    _contentController.text,
                  ),
                );
              },
              child: Text('게시'),
            ),
          ],
        ),
      ),
    );
  }
}

// 게시글 클래스
class Post {
  final String title;
  final String content;

  Post(this.title, this.content);
}

// 게시글 상세 화면 위젯
class PostDetailPage extends StatelessWidget {
  final Post post;

  PostDetailPage(this.post);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title), // 게시글 제목을 앱 바에 표시합니다.
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 게시글 내용 표시
            Text(post.content),
          ],
        ),
      ),
    );
  }
}