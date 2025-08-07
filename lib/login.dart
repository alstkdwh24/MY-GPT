import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gpt_project/domain.dart';
import 'package:flutter_gpt_project/joinPage.dart';
import 'package:flutter_gpt_project/main.dart';
import 'package:flutter_gpt_project/topPageHeader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Define your Kakao native app key here
  final String nativeAppKey =
      dotenv.env['nativeAppKey'] ?? 'YOUR_NATIVE_APP_KEY';
  final logger = Logger(); // 별도 인자 없이 생성
  final client_id = dotenv.env['client_id'];
  final String redirectUri = "$domain/api/naver/naverLoginComplete";
  // 누락된 변수들 추가
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _subscription;

  @override
  void initState() {
    super.initState();

    _appLinks = AppLinks();
    _subscription = _appLinks!.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        final link = uri.toString();
        logger.i("딥링크 수신: $link");

        if (link.startsWith("myapp://naverlogincomplete")) {
          logger.i("네이버 로그인 완료! MyHomePage로 이동합니다.");
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const MyHomePage(
                          title: 'MY GPT',
                          selectedOption: 'MY GPT',
                        ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: Duration(milliseconds: 400),
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerWidth = screenWidth < 400 ? screenWidth * 0.95 : 350;

    final double fontSize = screenWidth < 400 ? 16 : 18;
    final double titleFontSize = screenWidth < 400 ? 26 : 32;

    return Scaffold(
      resizeToAvoidBottomInset: true, // 기본값이지만 명시적으로 설정

      appBar: AppBar(title: const Text('Login Page')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: containerWidth,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'JO-GPT',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),
                // Kakao Login Button
                kakaoLogin(), //카카오 로그인 로직
                const SizedBox(height: 16),

                // Naver Loginㅂ Button (이미지 왼쪽, 텍스트 중앙)
                naverLogin(fontSize: fontSize),

                const SizedBox(height: 16),
                // Google Login Button
                googleLogin(fontSize: fontSize),
                const SizedBox(height: 16),
                // Apple Login Button
                non_memberLogin(fontSize: fontSize),
                const SizedBox(height: 16),
                // JO-JOHA 회원가입 Button
                My_gptJoin(fontSize: fontSize),
                const SizedBox(height: 16),
                // JO-JOHA 로그인 Button
                My_gptLogin(fontSize: fontSize),
                // 비회원 로그인 Button
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget kakaoLogin() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow[700],
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.zero,
      ),
      onPressed: () async {
        try {
          bool isInstalled = await isKakaoTalkInstalled();

          OAuthToken token;
          if (isInstalled) {
            // 카카오톡 앱 로그인
            token = await UserApi.instance.loginWithKakaoTalk();
            print('카카오톡으로 로그인 성공 ${token.accessToken}');
            kakaoUserInfo(token);
          } else {
            // 카카오계정(웹) 로그인
            token = await UserApi.instance.loginWithKakaoAccount();
            print('카카오계정으로 로그인 성공 ${token.accessToken}');
            kakaoUserInfo(token);
          }
          // 토큰을 Spring Boot 서버로 전송
        } catch (error) {
          logger.log(Level.error, '로그인 실패: $error');
          logger.i('nativeAppKey: $nativeAppKey'); // info 레벨로 출력
          // print('로그인 실패 $error');
        }
      },
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/kakao_login_large_wide.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Future<void> kakaoUserInfo(OAuthToken token) async {
    print('카카오 로그인 성공: ${token.accessToken}');
    try {
      final response = await http.post(
        Uri.parse("$domain/api/kakao/userInfo"),
        headers: {'Content-Type': "application/json"},
        body: jsonEncode({'accessToken': token.accessToken}),
      );
      print(response);
    } catch (error) {}
  }

  Widget naverLogin({required double fontSize}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var buttonWidth = constraints.maxWidth;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF03C75A),
            minimumSize: Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () async {
            try {
              // 먼저 로그아웃하여 깨끗한 상태로 시작

              // 네이버 OAuth URL로 직접 웹뷰 띄우기
              final String naverAuthUrl =
                  'https://nid.naver.com/oauth2.0/authorize?'
                  'response_type=code&'
                  'client_id=$client_id&' // 여기가 핵심!
                  'redirect_uri=$redirectUri&'
                  'state=RANDOM_STATE';
              if (await canLaunchUrl(Uri.parse(naverAuthUrl))) {
                await launchUrl(Uri.parse(naverAuthUrl));
              }
              if (await canLaunchUrl(Uri.parse(naverAuthUrl))) {
                await launchUrl(Uri.parse(naverAuthUrl));
              }
              logger.i(naverAuthUrl);
            } catch (e) {
              logger.log(Level.error, '네이버 로그인 실패: $e');
              // info 레벨로 출력
            }
          },
          child: SizedBox(
            width: double.infinity, // 버튼 전체 너비
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 6, // 버튼의 가장 왼쪽에 딱 붙임
                  child: Image.asset(
                    'assets/naver_icon.png',
                    width: 40,
                    height: 48,
                  ),
                ),

                Positioned(
                  left: 126,
                  child: Text(
                    '네이버 로그인',
                    style: TextStyle(color: Colors.white, fontSize: fontSize),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget googleLogin({required double fontSize}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: Size(double.infinity, 48),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        padding: EdgeInsets.zero,
      ),
      onPressed: () async {
        try {
          final url = Uri.parse('$domain/oauth2/authorization/google');

          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            logger.i('구글 로그인 페이지 열기 성공');
          } else {
            logger.log(Level.error, '구글 로그인 페이지를 열 수 없습니다.');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('구글 로그인을 실행할 수 없습니다. 다시 시도해주세요.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          logger.log(Level.error, '구글 로그인 오류: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('로그인 중 오류가 발생했습니다.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 14,
              child: SvgPicture.string(
                '''
<svg width="26" height="26" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>
              ''',
                width: 40,
                height: 24,
              ),
            ),
            const SizedBox(width: 12),
            Positioned(
              left: 130,
              child: Text(
                '구글 로그인',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget non_memberLogin({required double fontSize}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.zero,
        elevation: 0,
      ),
      onPressed: () {},
      child: SizedBox(
        width: double.infinity, // 버튼 전체 너비
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 7,
              child: Image.asset('assets/people.png', width: 40, height: 50),
            ),

            const SizedBox(width: 12),
            Positioned(
              right: 107,
              child: Text(
                '비회원 로그인',
                style: TextStyle(color: Colors.white, fontSize: fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget My_gptJoin({required double fontSize}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.zero,
        elevation: 0,
      ),
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const Joinpage(),
          ),
        );
      },
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 8,
              child: Image.asset('assets/mail.png', width: 40, height: 36),
            ),
            const SizedBox(width: 12),
            Positioned(
              right: 90,
              child: Text(
                'JO-GPT 회원가입',
                style: TextStyle(color: Colors.blue, fontSize: fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget My_gptLogin({required double fontSize}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.zero,
        elevation: 0,
      ),
      onPressed: () async {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const TopPageHeader(),
          ),
        );
      },
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 8,
              child: Image.asset('assets/user.png', width: 40, height: 36),
            ),
            const SizedBox(width: 12),
            Positioned(
              right: 100,
              child: Text(
                'JO-GPT 로그인',
                style: TextStyle(color: Colors.white, fontSize: fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
