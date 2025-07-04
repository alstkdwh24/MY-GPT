import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Joinpage extends StatefulWidget {
  const Joinpage({super.key});

  @override
  State<Joinpage> createState() => _JoinpageState();
}

class _JoinpageState extends State<Joinpage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  final orangeColor = Color.fromRGBO(255, 165, 0, 1.0);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: orangeColor,
        title: Text(
          "MY GPT",
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(246, 234, 216, 1)),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // 내용만큼만 세로 공간 차지
                children: [
                  Text(
                    'MY GPT JOIN',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: TextField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: '아이디',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: TextField(
                      controller: _pwController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '이름',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: '이메일',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: TextField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: '닉네임',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: orangeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        // 회원가입 처리 로직 작성
                        // idController.text, pwController.text 등 사용
                        final response = await http.post(
                          Uri.parse("http://172.30.1.81:8083/api/jwt/signUp"),
                          headers: {"Content-Type": "application/json"},
                          body:
                              {
                                "userId": _idController.text,
                                "userPw": _pwController.text,
                                "name": _nameController.text,
                                "email": _emailController.text,
                                "nickname": _nicknameController.text,
                              }.toString(),
                        );
                        response.body.isNotEmpty
                            ? print("회원가입 성공: ${response.body}")
                            : print("회원가입 실패: ${response.statusCode}");
                      },
                      child: const Text(
                        '회원가입',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
