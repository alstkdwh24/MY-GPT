import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gpt_project/domain.dart';
import 'package:flutter_gpt_project/main.dart';
import 'package:http/http.dart' as http;

class TopPageHeader extends StatefulWidget {
  const TopPageHeader({super.key});

  @override
  State<TopPageHeader> createState() => _TopPageHeader();
}

class _TopPageHeader extends State<TopPageHeader> {
  final orangeColor = Color.fromRGBO(255, 165, 0, 1.0);
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final boxWidth = width > 500 ? 420.0 : width * 0.9;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 165, 0, 1.0),
        title: const Text(
          "MY GPT",
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(246, 234, 216, 1),
        ),
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
                  const SizedBox(height: 24),

                  Container(
                    width: boxWidth,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final response = await http.post(
                          Uri.parse("$domain/api/jwt/login"),
                          headers: {"Content-Type": "application/json"},

                          body: jsonEncode({
                            "user_id": _idController.text,
                            "user_pw": _pwController.text,
                          }),
                        );
                        if (response.statusCode == 200) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      MyHomePage(
                                        title: "MY GPT",
                                        selectedOption: 'MY GPT',
                                      ),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration: Duration(
                                milliseconds: 400,
                              ), // 속도 조절
                            ),
                          );
                        } else {
                          print("로그인 실패: ${response.statusCode}");
                        }
                      },
                      child: Container(
                        child: Text(
                          "로그인",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(246, 234, 216, 1),
                          ),
                        ),
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
