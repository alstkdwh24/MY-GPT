import 'package:flutter/material.dart';

class TopPageHeader extends StatefulWidget {
  const TopPageHeader({super.key});

  @override
  State<TopPageHeader> createState() => _TopPageHeader();
}

class _TopPageHeader extends State<TopPageHeader> {
  final orangeColor = Color.fromRGBO(255, 165, 0, 1.0);

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
                      onPressed: () {},
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
