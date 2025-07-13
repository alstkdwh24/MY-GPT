import 'package:flutter/material.dart';
import 'package:flutter_gpt_project/join.dart';
import 'package:flutter_gpt_project/login.dart';

// ignore: camel_case_types
class LoginDrawMenu extends StatefulWidget {
  const LoginDrawMenu({super.key});

  @override
  State<LoginDrawMenu> createState() => _Login_draw_menuState();
}

class _Login_draw_menuState extends State<LoginDrawMenu> {
  @override
  Widget build(BuildContext context) {
    var inWidth = MediaQuery.of(context).size.width;
    var inHeight = MediaQuery.of(context).size.height;
    var orangeColor = Color.fromRGBO(255, 165, 0, 1.0);
    List<String> items = ['닉네임', '이메일', '이름'];
    return Drawer(
      width: inWidth,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Center(
                child: Row(
                  children: [
                    Container(
                      width: inWidth * 0.36,
                      height: MediaQuery.of(context).size.height,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(width: inWidth * 0.04),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        var insHeight = constraints.maxHeight;
                        return Center(
                          child: Container(
                            width: inWidth * 0.50,
                            child: Column(
                              children: List.generate(
                                items.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: insHeight * 0.26,
                                        width: inWidth * 0.3,
                                        child: Center(
                                          child: Text(items[index]),
                                        ),
                                      ),
                                      Container(
                                        height: insHeight * 0.26,

                                        child: Center(child: Text("1")),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: inHeight * 0.12,
            child: Center(
              child: DrawerHeader(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: inWidth * 0.4,
                          height: MediaQuery.of(context).size.height * 0.0635,

                          decoration: BoxDecoration(
                            color: orangeColor, // 배경색

                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => LoginPage(),
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
                            },
                            child: Text(
                              '로그인',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: inWidth * 0.1),
                    Column(
                      children: [
                        Container(
                          width: inWidth * 0.4,
                          height: MediaQuery.of(context).size.height * 0.0635,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,

                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => Join(),
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
                            },
                            child: Text(
                              '회원가입',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(title: Text('항목 1')),
          ListTile(title: Text('항목 2')),
          ListTile(
            leading: Icon(Icons.close),
            title: Text('닫기'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
