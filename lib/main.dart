import 'package:flutter/material.dart';
import 'package:hackdol1_1/homepage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hackdol1_1/pages/join.dart';
import 'package:flutter/material.dart';
import 'package:hackdol1_1/components/custom_form.dart';
import 'package:hackdol1_1/components/logo.dart';
import 'package:hackdol1_1/size.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test title"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/registration");
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            child: const Text("회원가입"), // 수정된 부분: 버튼 텍스트를 "회원가입"으로 변경
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: xlargeGap),
            Logo("Login"),
            SizedBox(height: largeGap), // 1. 추가
            CustomForm(), // 2. 추가
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
