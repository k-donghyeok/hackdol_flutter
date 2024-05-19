import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FreeBoardPage(),
    );
  }
}

class FreeBoardPage extends StatefulWidget {
  @override
  _FreeBoardPageState createState() => _FreeBoardPageState();
}

class _FreeBoardPageState extends State<FreeBoardPage> {
  List<Post> posts = [];



  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  void _fetchPosts() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('posts').get();
    setState(() {
      posts = querySnapshot.docs.map((doc) {
        return Post(
          doc.id,
          doc['title'],
          doc['content'],
          doc['author'],
          doc['createdAt'].toDate(),
        );
      }).toList();
    });
  }

  void refreshPosts() {
    _fetchPosts();
  }

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
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void _openWritePostPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritePostPage(),
      ),
    );

    if (result != null) {
      refreshPosts();
    }
  }

  void _openPostDetailPage(BuildContext context, Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(post),
      ),
    );

    if (result != null && result == true) {
      refreshPosts();
    }
  }

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
            SizedBox(height: 10),
            Text(
              '공지사항',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showUsageGuide(context);
              },
              child: Text('자유게시판 사용 방법'),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: posts.map((post) {
                return GestureDetector(
                  onTap: () {
                    _openPostDetailPage(context, post);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(post.title),
                      SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          Text('글쓴 사람: ${post.author}'),
                          Spacer(),
                          Text(
                            '올린 날짜: ${DateFormat('yyyy-MM-dd').format(post.createdAt)}',
                          ),
                        ],
                      ),
                      Text(post.content),
                      Divider(),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () {
                  _openWritePostPage(context);
                },
                child: Text('글쓰기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WritePostPage extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

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
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
              ),
              maxLines: 5,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: '글쓴이',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _uploadPost(context);
              },
              child: Text('게시'),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadPost(BuildContext context) async {
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목, 내용, 작성자를 모두 입력해주세요.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'author': _authorController.text,
        'createdAt': DateTime.now(),
      });
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시물이 성공적으로 작성되었습니다.')),
      );
    } catch (e) {
      print('게시물을 업로드하는 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시물을 업로드하는 중 오류가 발생했습니다.')),
      );
    }
  }
}

class PostDetailPage extends StatelessWidget {
  final Post post;

  PostDetailPage(this.post);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(post.content),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showDeleteDialog(context);
              },
              child: Text('게시물 삭제'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('게시물 삭제'),
          content: Text('게시물을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _deletePost(context);
              },
              child: Text('예'),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(BuildContext context) async {
    await FirebaseFirestore.instance.collection('posts').doc(post.id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('게시물이 성공적으로 삭제되었습니다.')),
    );
    // 게시물이 삭제된 후에 화면을 다시 갱신
    Navigator.pop(context, true);
    Navigator.of(context).pop();
  }
}

class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;

  Post(this.id, this.title, this.content, this.author, this.createdAt);
}
