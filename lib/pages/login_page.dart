import 'package:flutter/material.dart';
import 'package:hackdol1_1/components/custom_form.dart';
import 'package:hackdol1_1/components/logo.dart';
import 'package:hackdol1_1/size.dart';

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
