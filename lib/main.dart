import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hackdol1_1/homepage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hackdol1_1/pages/join.dart';
import 'package:hackdol1_1/components/custom_form.dart';
import 'package:hackdol1_1/components/logo.dart';
import 'package:hackdol1_1/size.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hackdol1_1/block_tell.dart';
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
  static const platform = MethodChannel('com.example.hackdol1_1/spam_detection');

  @override
  void initState() {
    super.initState();
    _initializeApp();

    // 네이티브(Android)로부터 메시지 수신을 처리하는 핸들러 설정
    platform.setMethodCallHandler(_handleNativeMessage);
  }

  Future<void> _initializeApp() async {
    // 여기에 앱이 처음 실행되었을 때 호출할 함수를 작성합니다.
    print("앱이 처음 실행되었습니다.");
  }

  Future<void> _handleNativeMessage(MethodCall call) async {
    if (call.method == "smsReceived") {
      String message = call.arguments["message"];
      bool isSpam = call.arguments["isSpam"];
      _showPopupMessage(message, isSpam);
    }
  }

  void _showPopupMessage(String message, bool isSpam) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isSpam ? "Spam SMS Received" : "New SMS Received"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
