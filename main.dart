import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gpt_project/domain.dart';
import 'package:flutter_gpt_project/draw_menu.dart';
import 'package:flutter_gpt_project/login.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {'/login': (context) => const LoginPage()},
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.selectedOption,
  });

  final String title;
  final String selectedOption;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late String _selectedOption;
  final orangeColor = Color.fromRGBO(255, 165, 0, 1.0);

  final List<String> _options = ['MY GPT', 'MY LIMDA GPT'];

  Logger logger = Logger('MyHomePageState');
  String _response = "Loading....";
  AppLinks? _appLinks;
  final TextEditingController _gptTextController = TextEditingController();
  final TextEditingController _gptListTextController = TextEditingController();
  List<String> messages = [];
  final List<String> _gptList = [];
  final bool _isLoading = false;
  StreamSubscription<Uri>? _subscription;
  late AnimationController _controller;
  late Animation<int> _dotCount;
  List<Map<String, String>> message = [];
  late String nickName;

  // ignore: prefer_typing_uninitialized_variables
  late final gptContents;

  @override
  void initState() {
    super.initState();

    _selectedOption = widget.selectedOption;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotCount = StepTween(begin: 0, end: 4).animate(_controller);

    _gptTextController.clear();
    _gptList.clear();
    messages.clear();

    _startGptRoom();

    _appLinks = AppLinks();

    _subscription = _appLinks!.uriLinkStream.listen((Uri? uri) {
      if (uri != null &&
          uri.scheme == "myapp" &&
          uri.host == "naverloginComplete") {
        logger.info("Naver login completed with URI: $uri");
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
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

  Future<void> _startGptRoom() async {
    try {
      final response = await http.post(
        Uri.parse('$domain/api/gpt/rooms/createGptRoom'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'roomName': 'My GPT Room'}),
      );
      print("채팅방이 생성되었습니다. ${response.body}");
      final data = jsonDecode(response.body);
      gptContents = data["room_id"];
      print(gptContents + "채팅방의 정보가 나왔습니다.");
    } catch (e) {
      logger.severe("Error starting GPT room: $e");
      setState(() {
        _response = "GPT 방 시작 오류: $e";
      });
    }
  }

  Future<void> _sendGptRequest({required bool isLimda}) async {
    final userInput = _gptTextController.text.trim();
    if (userInput.isEmpty) return;
    setState(() {
      _gptList.add("나:  $userInput");
      _gptList.add("GPT: loading...");
      messages.add("나:  $userInput");
      _gptTextController.clear();
    });
    final message =
        messages.map((msg) => {'role': 'user', 'content': msg}).toList();
    final urls =
        isLimda
            ? [
              '$domain/api/askGPT/GPTAsk',
              'http://10.0.2.2:443/api/askGPT/GPTAsk',
            ]
            : [
              '$domain/api/askGPT/groqAsk',
              'http://10.0.2.2:443/api/askGPT/groqAsk',
            ];
    final roomContent = "$domain/api/gpt/rooms/createGptContents";
    for (var url in urls) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'messages': message}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final gptResponse =
              data['choices'][0]['message']['content'] ??
              'No response from GPT';

          try {
            final gptContentsResponse = await http
                .post(
                  Uri.parse(roomContent),
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: jsonEncode({
                    'room_id': gptContents,
                    'content': userInput,
                  }),
                )
                .timeout(Duration(seconds: 10));

            print(
              "채팅방에 메시지를 저장했습니다. Status: ${gptContentsResponse.statusCode}",
            );
          } catch (e) {
            print("채팅방 저장 실패: $e");
          }
          if (!mounted) return;

          setState(() {
            final lastIndex = _gptList.lastIndexWhere(
              (msg) => msg.startsWith("GPT: loading"),
            );
            if (lastIndex != -1) _gptList[lastIndex] = "GPT: $gptResponse";
            messages.add("GPT: $gptResponse");
          });

          return;
        }
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        final lastIndex = _gptList.lastIndexWhere(
          (msg) => msg.startsWith("GPT: loading"),
        );
        if (lastIndex != -1) _gptList[lastIndex] = "GPT: 네트워크 오류";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inHeight = MediaQuery.of(context).size.height;
    final inWidth = MediaQuery.of(context).size.width;
    late final gptContents;
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                    child: ListBuilder(),
                  ),
                ],
              ),
            ),
            bottom(),
          ],
        ),
      ),
    );
  }

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
                (isUser || msg != "GPT: loading...")
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

  Widget bottom() {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Container(
        decoration: BoxDecoration(color: orangeColor),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8),
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
                                _sendGptRequest(
                                  isLimda: _selectedOption == "MY LIMDA GPT",
                                );
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
                            _sendGptRequest(
                              isLimda: _selectedOption == "MY LIMDA GPT",
                            );
                          } else if (_selectedOption == "MY LIMDA GPT") {
                            _sendGptRequest(
                              isLimda: _selectedOption == "MY LIMDA GPT",
                            );
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