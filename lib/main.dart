import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hackdol1_1/homepage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hackdol1_1/pages/join.dart';
import 'package:hackdol1_1/components/custom_form.dart';
import 'package:hackdol1_1/components/logo.dart';
import 'package:hackdol1_1/size.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hackdol1_1/block_tell.dart'; // block_tell.dart 파일 import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'myfirebase.dart';
import 'nativeCommunication.dart';
import 'popup_screen.dart'; // popup_screen.dart 파일 import

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
  final FirebaseService _firebaseService = FirebaseService(); // FirebaseService 인스턴스 생성
  List<String> _blockedNumbers = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
    platform.setMethodCallHandler(_handleNativeMessage);
  }

  Future<void> _initializeApp() async {
    try {
      List<String> blockedNumbers = await _firebaseService.loadBlockedNumbers();
      setState(() {
        _blockedNumbers = blockedNumbers;
      });
      NativeCommunication.updateBlockedNumbers(_blockedNumbers);
      print("앱이 처음 실행되었습니다.");
    } catch (e) {
      print('Error loading blocked numbers: $e');
    }
  }

  Future<void> _handleNativeMessage(MethodCall call) async {
    if (call.method == "smsReceived") {
      String message = call.arguments["message"];
      bool isSpam = call.arguments["isSpam"];
      String sender = call.arguments["sender"];
      _showPopupMessage(message, isSpam, sender);
    }
  }

  void _showPopupMessage(String message, bool isSpam, String sender) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PopupScreen(
          message: message,
          sender: sender,
          isSpam: isSpam,
          onBlock: () => _blockPhoneNumber(sender),
        ),
      ),
    );
  }

  Future<void> _blockPhoneNumber(String phoneNumber) async {
    if (_blockedNumbers.contains(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$phoneNumber is already blocked.')),
      );
      return;
    }

    try {
      await _firebaseService.blockPhoneNumber(phoneNumber);
      setState(() {
        _blockedNumbers.add(phoneNumber);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$phoneNumber has been blocked.')),
      );
      NativeCommunication.updateBlockedNumbers(_blockedNumbers);
    } catch (error) {
      print('Error blocking phone number: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to block phone number.')),
      );
    }
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
