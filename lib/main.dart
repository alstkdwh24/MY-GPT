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
      home: const MyHomePage(title: 'My GPT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Logger logger = Logger('MyHomePageState');
  String _response = "Loading...";
  AppLinks? _appLinks;
  final TextEditingController _gptTextController = TextEditingController();
  final TextEditingController _gptListTextController = TextEditingController();
  List<String> messages = [];
  List<String> _gptList = [];

  StreamSubscription<Uri>? _subscription;

  void initState() {
    super.initState();
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
    super.dispose();
  }

  Future<void> fetchData() async {
    final url = Uri.parse('http://3.38.89.59:8083/api/hello');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _response = response.body;
        });
      } else {
        setState(() {
          _response = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
    }

    // 여기에 API 호출이나 데이터베이스 쿼리 등을 추가하여 데이터를 가져옵니다.
    // 예시로, 2초 후에 "Hello, World!"를 응답으로 설정합니다.
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _response = "Hello, World!";
    });
  }

  Future<void> _sendGptRequest() async {
    final userInput = _gptTextController.text.trim();
    if (userInput.isEmpty) return;

    _gptListTextController.text = messages.join('\n');

    setState(() {
      _gptList.add("나:  ${_gptTextController.text}");
      messages.add("나:  ${_gptTextController.text}"); // 사용자의 질문도 누적
      _gptTextController.clear(); // 입력창 비우기
    });

    _gptListTextController.text = messages.join('\n');

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
          _gptList.add("GPT: $gptResponse");
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
    final orangeColor = Color.fromRGBO(255, 165, 0, 1.0);
    final inHeight = MediaQuery.of(context).size.height;
    final inWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true, // 기본값이지만 명시적으로 설정
      appBar: AppBar(backgroundColor: orangeColor, title: Text(widget.title)),
      drawer: const DrawMenuOne(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(246, 234, 216, 1),
                ),
                width: double.infinity,
                // 여기에 실제 대화 내용이나 리스트 등을 배치
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _gptList.length,
                  itemBuilder: (context, index) {
                    final msg = _gptList[index];
                    final isUser = msg.startsWith("나: ");
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,

                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isUser
                                  ? orangeColor.withOpacity(0.8)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
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
                              textAlign:
                                  isUser ? TextAlign.right : TextAlign.left,
                            ),
                            SizedBox(height: 4),
                            SelectableText(
                              isUser
                                  ? msg.replaceFirst("나: ", "")
                                  : msg.replaceFirst("GPT: ", ""),
                              style: TextStyle(fontSize: 16),
                              textAlign:
                                  isUser ? TextAlign.right : TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SafeArea(
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
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
                                  setState(() {});
                                  _sendGptRequest();
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
            ),
          ],
        ),
      ),
    );
    // ...existing code...
  }
}
