import 'package:flutter/material.dart';
import 'package:hackdol1_1/homepage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hackdol1_1/pages/join.dart';
import 'package:flutter/material.dart';
import 'package:hackdol1_1/components/custom_form.dart';
import 'package:hackdol1_1/components/logo.dart';
import 'package:hackdol1_1/size.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hackdol1_1/block_tell.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'myfirebase.dart';
import 'nativeCommunication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {


    // 여기에 앱이 처음 실행되었을 때 호출할 함수를 작성합니다.
    print("앱이 처음 실행되었습니다.");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            minimumSize: const Size(400, 60),
          ),
        ),
      ),
      initialRoute: "/login",
      routes: {
        "/login": (context) => LoginPage(),
        "/home": (context) => MainScreen(),
        "/registration": (context) => RegistrationForm(),
      },
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    // 여기에 페이지가 처음 실행되었을 때 호출할 함수를 작성합니다.
    print("LoginPage가 처음 실행되었습니다.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: xlargeGap),
            Logo("Login"),
            SizedBox(height: largeGap),
            CustomForm(),
          ],
        ),
      ),
    );
  }
}


/*
class RegistrationForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원 가입"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '이름',
                ),
              ),
              // 다른 폼 필드 추가
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '이메일',
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 회원가입 버튼 클릭 시 처리할 내용
                },
                child: const Text("회원가입"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 */
