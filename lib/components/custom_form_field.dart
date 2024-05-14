import 'package:flutter/material.dart';
import 'package:hackdol1_1/size.dart';

class CustomTextFormField extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator; // 수정: validator 필드 추가
  final bool obscureText; // 수정: obscureText 필드 추가

  const CustomTextFormField({
    required this.text,
    required this.controller,
    required this.validator,
    required this.obscureText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text),
        SizedBox(height: smallGap),
        TextFormField(
          controller: controller,
          validator: validator, // 수정: validator 전달
          obscureText: obscureText, // 수정: obscureText 전달
          decoration: InputDecoration(
            hintText: "Enter $text",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
