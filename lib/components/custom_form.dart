import 'package:flutter/material.dart';
import 'package:hackdol1_1/components/custom_form_field.dart';
import 'package:hackdol1_1/size.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            obscureText: false, // 이메일 필드는 비밀번호 필드가 아니므로 false 설정
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
            obscureText: true, // 비밀번호 필드는 **** 처리
          ),
          SizedBox(height: largeGap),
          ElevatedButton(
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
