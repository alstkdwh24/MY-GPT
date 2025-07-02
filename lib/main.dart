import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gpt_project/draw_menu.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  KakaoSdk.init(
    nativeAppKey: dotenv.env['nativeAppKey'],
    javaScriptAppKey: dotenv.env['javaScriptKey'],
  );

  // FlutterNaverLogin.init is not defined; initialization is not required or handled differently in the latest package version.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'MY GPT', selectedOption: 'MY GPT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.selectedOption,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String selectedOption; // 추가

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  //변수들
  late String _selectedOption;
  final orangeColor = Color.fromRGBO(255, 165, 0, 1.0);

  final List<String> _options = ['MY GPT', 'MY LIMDA GPT'];

  Logger logger = Logger('MyHomePageState');
  String _response = "Loading....";
  AppLinks? _appLinks;
  final TextEditingController _gptTextController = TextEditingController();
  final TextEditingController _gptListTextController = TextEditingController();
  List<String> messages = [];
  List<String> _gptList = [];
  bool _isLoading = false;
  StreamSubscription<Uri>? _subscription;
  late AnimationController _controller;
  late Animation<int> _dotCount;
  List<Map<String, String>> message = [];
  void initState() {
    super.initState();
    _selectedOption = widget.selectedOption;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotCount = StepTween(begin: 0, end: 4).animate(_controller);

    // 입력창과 메시지 리스트도 초기화
    _gptTextController.clear();
    _gptList.clear();
    messages.clear();

    _appLinks = AppLinks();

    _subscription = _appLinks!.uriLinkStream.listen((Uri? uri) {
      if (uri != null &&
          uri.scheme == "myapp" &&
          uri.host == "naverloginComplete") {
        logger.info("Naver login completed with URI: $uri");
      }
    });
    // fetchData();
    // 초기화 작업을 여기에 추가할 수 있습니다.
    // 예를 들어, API 호출이나 데이터베이스 초기화 등을 수행할 수 있습니다.
  }

  void dispose() {
    _subscription?.cancel();
    _controller.dispose(); // AnimationController 해제
    super.dispose();
  }

  void pageChange() {
    if (_selectedOption == "MY GPT") {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, vsecondaryAnimation) => MyHomePage(
                key: UniqueKey(),
                title: 'MY LIMDA GPT',
                selectedOption: "MY LIMDA GPT",
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 400),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => MyHomePage(
                selectedOption: "MY GPT",
                key: UniqueKey(),
                title: "MY GPT",
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 400),
        ),
      );
    }
  }

  Future<void> _sendLimdaGptRequest() async {
    final userInput = _gptTextController.text.trim();

    if (userInput.isEmpty) return;

    setState(() {
      _gptList.add("나:  ${_gptTextController.text}");
      _gptList.add("GPT: loading..."); // 1. GPT 로딩 말풍선 추가

      messages.add("나:  ${_gptTextController.text}"); // 사용자의 질문도 누적
      message =
          messages.map((msg) => {'role': 'user', 'message': msg}).toList();

      _gptTextController.clear(); // 입력창 비우기
    });

    print("Search button pressed");
    try {
      final response = await http.post(
        Uri.parse('http://192.168.110.215:8083/api/askGPT/GPTAsk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      print("jsonRequest: ${jsonEncode({'message': message})}");

      print("Response status code: ${response.body}");
      final Map<String, dynamic> data = jsonDecode(response.body);
      print("Response data: $data");
      String gptResponse =
          data['choices'][0]['message']['content'] ?? 'No response from GPT';
      print("GPT Response: $gptResponse");
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false; // 1. 로딩 먼저 끄기
          final lastIndex = _gptList.lastIndexWhere(
            (msg) => msg.startsWith("GPT: loading"),
          );
          if (lastIndex != -1) {
            _gptList[lastIndex] = "GPT: $gptResponse"; // 2. 로딩 말풍선 업데이트
          }
          messages.add("GPT: $gptResponse");
          List<Map<String, String>> message =
              messages.map((msg) => {'role': 'user', 'message': msg}).toList();

          _response = utf8.decode(response.bodyBytes); // 한글 깨짐 방지
        });
      } else {
        setState(() {
          _response = "오류 발생: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "네트워크 오류: $e";
        _gptTextController.clear(); // 입력창 비우기
      });
    }
  }

  Future<void> _sendGptRequest() async {
    final userInput = _gptTextController.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      _gptList.add("나:  ${_gptTextController.text}");
      _gptList.add("GPT: loading..."); // 1. GPT 로딩 말풍선 추가

      messages.add("나:  ${_gptTextController.text}"); // 사용자의 질문도 누적

      _gptTextController.clear(); // 입력창 비우기
    });

    print("Search button pressed");
    try {
      final response = await http.post(
        Uri.parse('http://3.38.89.59:8083/api/askGPT/groqAsk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userInput}),
      );
      print("Response status code: ${response.body}");
      final Map<String, dynamic> data = jsonDecode(response.body);
      print("Response data: $data");
      String gptResponse =
          data['choices'][0]['message']['content'] ?? 'No response from GPT';
      print("GPT Response: $gptResponse");
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false; // 1. 로딩 먼저 끄기

          final lastIndex = _gptList.lastIndexWhere(
            (msg) => msg.startsWith("GPT: loading"),
          );
          if (lastIndex != -1) {
            _gptList[lastIndex] = "GPT: $gptResponse"; // 2. 로딩 말풍선 업데이트
          }
          messages.add("GPT: $gptResponse");

          _response = utf8.decode(response.bodyBytes); // 한글 깨짐 방지
        });
      } else {
        setState(() {
          _response = "오류 발생: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "네트워크 오류: $e";
        _gptTextController.clear(); // 입력창 비우기
      });
    }
    // 여기에 GPT 요청을 보내는 로직을 추가합니다.
    // 예시로, 2초 후에 "GPT Response"를 응답으로 설정합니다.
  }

  @override
  Widget build(BuildContext context) {
    final inHeight = MediaQuery.of(context).size.height;
    final inWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true, // 기본값이지만 명시적으로 설정
      appBar: AppBar(
        backgroundColor: orangeColor,
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(246, 234, 216, 1),
                foregroundColor: Colors.black,

                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                pageChange();
              },

              child: Text(
                (_selectedOption == "MY GPT") ? "MY LIMDA GPT" : "MY GPT",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      drawer: const DrawMenuOne(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(246, 234, 216, 1),
                    ),
                    width: double.infinity,
                    // 여기에 실제 대화 내용이나 리스트 등을 배치
                    child: ListBuilder(), // 리스트 뷰 빌더 호출
                  ),
                ],
              ),
            ),
            bottom(), // 하단 입력창 및 버튼
          ],
        ),
      ),
    );
    // ...existing code...
  }

  //리스트 뷰 빌더 부분
  Widget ListBuilder() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _gptList.length,
      itemBuilder: (context, index) {
        final msg = _gptList[index];
        final isUser = msg.startsWith("나: ");
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,

          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? orangeColor.withOpacity(0.8) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                (isUser || msg != "GPT: loading...") // 로딩 말풍선 제외
                    ? Column(
                      crossAxisAlignment:
                          isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          isUser ? "나" : "GPT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          textAlign: isUser ? TextAlign.right : TextAlign.left,
                        ),
                        SizedBox(height: 4),
                        SelectableText(
                          isUser
                              ? msg.replaceFirst("나: ", "")
                              : msg.replaceFirst("GPT: ", ""),
                          style: TextStyle(fontSize: 16),
                          textAlign: isUser ? TextAlign.right : TextAlign.left,
                        ),
                      ],
                    )
                    : AnimatedBuilder(
                      animation: _dotCount,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              "GPT",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '.' * _dotCount.value,
                              style: TextStyle(
                                fontSize: 36,
                                color: orangeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          ),
        );
      },
    );
  }

  // 하단 입력창 및 버튼
  Widget bottom() {
    // TODO: Implement your widget here
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Container(
        decoration: BoxDecoration(color: orangeColor),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8), // 하단 여백 추가
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.076,
              child: Row(
                children: [
                  Flexible(flex: 2, child: Container()),
                  Flexible(
                    flex: 27,
                    child: SizedBox(
                      child: LayoutBuilder(
                        builder: (
                          BuildContext context,
                          BoxConstraints constraints,
                        ) {
                          var width = constraints.maxWidth;
                          var height = constraints.maxHeight;
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            width: width * 0.93,
                            height: height * 0.76,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: TextField(
                              maxLines: 1,
                              controller: _gptTextController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              onSubmitted: (value) {
                                _sendGptRequest();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Flexible(flex: 2, child: Container()),
                  Flexible(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          if (_selectedOption == "MY GPT") {
                            await _sendGptRequest();
                          } else {
                            await _sendLimdaGptRequest();
                          }
                        },
                        icon: Icon(
                          Icons.search_rounded,
                          size: 32,
                          color: orangeColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
