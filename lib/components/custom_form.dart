import 'package:flutter/material.dart';
import 'package:hackdol1_1/components/custom_form_field.dart';
import 'package:hackdol1_1/size.dart';
import 'package:hackdol1_1/pages/join.dart';

class CustomForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  CustomForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextFormField("Email"),
          SizedBox(height: mediumGap),
          CustomTextFormField("Password"),
          SizedBox(height: largeGap),
          // 로그인 버튼과 회원가입 버튼 추가
          TextButton(
            onPressed: () {
              // 유효성 검사 제거
              Navigator.pushNamed(context, "/home");
            },
            child: Text("Login"),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              // 유효성 검사 제거
              Navigator.pushNamed(context, "/registration");
            },
            child: Text("join"),
          )
        ],
      ),
    );
  }
}