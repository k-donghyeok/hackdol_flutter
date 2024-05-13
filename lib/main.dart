import 'package:flutter/material.dart';
import 'package:hackdol1_1/homepage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hackdol1_1/pages/login_page.dart';
import 'package:hackdol1_1/pages/join.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key:key);

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
            minimumSize: Size(400,60),
          ),
        ),
      ),
      initialRoute: "/login",
      routes: {
        "/login": (context) => LoginPage(),
        "/home" : (context) => MainScreen(),
        "/registration" : (context) => RegistrationForm(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

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
            child: Text("회원가입"), // 수정된 부분: 버튼 텍스트를 "회원가입"으로 변경
          ),
        ),
      ),
    );
  }
}