import 'package:flutter/material.dart';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  String? _phoneNumber;
  String? _gender;
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: '이름'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이름을 입력해주세요';
              }
              return null;
            },
            onSaved: (value) {
              _name = value;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: '전화번호'),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '전화번호를 입력해주세요';
              }
              return null;
            },
            onSaved: (value) {
              _phoneNumber = value;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: '이메일'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              return null;
            },
            onSaved: (value) {
              _email = value;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: '비밀번호'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              return null;
            },
            onSaved: (value) {
              _password = value;
            },
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: '성별'),
            value: _gender,
            onChanged: (value) {
              setState(() {
                _gender = value;
              });
            },
            items: ['남자', '여자', '기타'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '성별을 선택해주세요';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // 회원가입 정보를 저장하거나 다른 작업 수행
                // 예: AuthService().register(name, phoneNumber, gender, email, password);
              }
            },
            child: Text('회원가입'),
          ),
        ],
      ),
    );
  }
}