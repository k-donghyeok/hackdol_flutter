import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hackdol1_1/homepage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hackdol1_1/pages/join.dart';
import 'package:hackdol1_1/components/custom_form.dart';
import 'package:hackdol1_1/components/custom_form_field.dart';
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
  bool _isLoading = true;
  User? _user;
  late OverlayEntry overlayEntry;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    platform.setMethodCallHandler(_handleNativeMessage);
    _checkUser();
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

  Future<void> _checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    if (email != null && password != null) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        setState(() {
          _user = userCredential.user;
        });
      } catch (e) {
        print('자동 로그인 실패: $e');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleNativeMessage(MethodCall call) async {
    if (call.method == "smsReceived") {
      String message = call.arguments["message"];
      bool isSpam = call.arguments["isSpam"];
      String sender = call.arguments["sender"];
      print('플러터 에서 수신완료 $message,$isSpam,$sender');
      _showPopupMessage(message, isSpam, sender);
    }
  }

  void _showPopupMessage(String message, bool isSpam, String sender) {
    OverlayState? overlayState = Overlay.of(context);
    if (overlayState == null) {
      print('OverlayState is null');
      return;
    }

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: 10.0,
        right: 10.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isSpam ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Message from $sender',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 10),
                if (isSpam)
                  ElevatedButton(
                    onPressed: () {
                      _blockPhoneNumber(sender);
                      overlayEntry.remove();
                    },
                    child: Text('Block'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    overlayEntry.remove();
                  },
                  child: Text('Close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(Duration(seconds: 5), () {
      overlayEntry.remove();
    });
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
      home: _isLoading
          ? Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      )
          : _user == null
          ? LoginPage()
          : MainScreen(),
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
            CustomForm(), // 수정된 CustomForm 사용
          ],
        ),
      ),
    );
  }
}

class CustomForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  CustomForm({Key? key}) : super(key: key);

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // 로그인 정보 SharedPreferences에 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);

      print('Successfully logged in: ${userCredential.user!.uid}');
      Navigator.pushNamed(context, "/home");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed. Please check your email and password.'),
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextFormField(
            text: "이메일",
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요.';
              }
              return null;
            },
            obscureText: false,
          ),
          SizedBox(height: mediumGap),
          CustomTextFormField(
            text: "비밀번호",
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요.';
              }
              return null;
            },
            obscureText: true,
          ),
          SizedBox(height: largeGap),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _login(context);
              }
            },
            child: Text("Login"),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/registration");
            },
            child: Text("Join"),
          ),
        ],
      ),
    );
  }
}
