import 'package:flutter/material.dart';
import 'package:flutter_gpt_project/join.dart';
import 'package:flutter_gpt_project/login.dart';

class DrawMenuOne extends StatefulWidget {
  const DrawMenuOne({super.key});

  @override
  State<DrawMenuOne> createState() => _DrawMenuState();
}

class _DrawMenuState extends State<DrawMenuOne> {
  @override
  Widget build(BuildContext context) {
    var inWidth = MediaQuery.of(context).size.width;
    var inHeight = MediaQuery.of(context).size.height;
    var orangeColor = Color.fromRGBO(255, 165, 0, 1.0);

    return Drawer(
      width: inWidth,
      child: ListView(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                Container(
                  width: inWidth * 0.4,
                  height: MediaQuery.of(context).size.height * 0.08,

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
                              (context, animation, secondaryAnimation) =>
                                  LoginPage(),
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
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(width: inWidth * 0.1),
                Container(
                  width: inWidth * 0.4,
                  height: MediaQuery.of(context).size.height * 0.08,
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
                              (context, animation, secondaryAnimation) =>
                                  Join(),
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
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
              ],
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
