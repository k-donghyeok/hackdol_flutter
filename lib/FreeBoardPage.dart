import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FreeBoardPage extends StatefulWidget {
  @override
  _FreeBoardPageState createState() => _FreeBoardPageState();
}

class _FreeBoardPageState extends State<FreeBoardPage> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final snapshot = await FirebaseFirestore.instance.collection('posts').get();
    final postsData = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      posts = postsData;
    });
  }

  Future<void> addPost(Post post) async {
    final docRef = await FirebaseFirestore.instance.collection('posts').add({
      'title': post.title,
      'content': post.content,
    });
    post.id = docRef.id; // Firestore 문서 ID를 저장합니다.
    setState(() {
      posts.add(post);
    });
  }

  Future<void> deletePost(Post post) async {
    await FirebaseFirestore.instance.collection('posts').doc(post.id).delete();
    setState(() {
      posts.remove(post);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자유게시판'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(post.title),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _confirmDeletePost(context, post);
                        },
                      ),
                      onTap: () {
                        _openPostDetailPage(context, post);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openWritePostPage(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
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
        builder: (context) => WritePostPage(), // 글쓰기 페이지로 이동합니다.
      ),
    );

    if (result != null) {
      addPost(result);
    }
  }

  void _openPostDetailPage(BuildContext context, Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(post),
      ),
    );
  }

  void _confirmDeletePost(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('정말로 이 게시물을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('아니요'),
            ),
            TextButton(
              onPressed: () {
                deletePost(post);
                Navigator.of(context).pop();
              },
              child: Text('예'),
            ),
          ],
        );
      },
    );
  }
}

class WritePostPage extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 작성'),
        backgroundColor: Colors.blue,
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
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  Post(
                    _titleController.text,
                    _contentController.text,
                  ),
                );
              },
              child: Text('게시'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Post {
  String? id;
  final String title;
  final String content;

  Post(this.title, this.content, {this.id});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      doc['title'],
      doc['content'],
      id: doc.id,
    );
  }
}

class Comment {
  String? id;
  final String postId;
  final String content;
  final DateTime timestamp;

  Comment(this.postId, this.content, this.timestamp, {this.id});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      doc['postId'],
      doc['content'],
      (doc['timestamp'] as Timestamp).toDate(),
      id: doc.id,
    );
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
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              post.content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Expanded(
              child: CommentSection(post.id!),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentSection extends StatefulWidget {
  final String postId;

  CommentSection(this.postId);

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  List<Comment> comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .get();
    final commentsData = snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    setState(() {
      comments = commentsData;
    });
  }

  Future<void> addComment(String content) async {
    final newComment = Comment(
      widget.postId,
      content,
      DateTime.now(),
    );

    final docRef = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'postId': newComment.postId,
      'content': newComment.content,
      'timestamp': newComment.timestamp,
    });

    setState(() {
      comments.insert(0, Comment(newComment.postId, newComment.content, newComment.timestamp, id: docRef.id));
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return ListTile(
                title: Text(comment.content),
                subtitle: Text(comment.timestamp.toString()),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: '댓글을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  addComment(_commentController.text);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FreeBoardPage(),
    );
  }
}
