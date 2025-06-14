import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gpt_project/draw_menu.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

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
  String _response = "Loading...";

  void initState() {
    super.initState();
    // fetchData();
    // 초기화 작업을 여기에 추가할 수 있습니다.
    // 예를 들어, API 호출이나 데이터베이스 초기화 등을 수행할 수 있습니다.
  }

  Future<void> fetchData() async {
    final url = Uri.parse('http://localhost:8083/api/hello');

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

  @override
  Widget build(BuildContext context) {
    final orangeColor = Color.fromRGBO(255, 165, 0, 1.0);
    final inHeight = MediaQuery.of(context).size.height;
    final inWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true, // 기본값이지만 명시적으로 설정

      appBar: AppBar(backgroundColor: orangeColor, title: Text(widget.title)),
      drawer: const DrawMenuOne(),

      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column의 높이를 최소화

          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(246, 234, 216, 1),
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.86 - 80,
            ),
            Container(
              decoration: BoxDecoration(color: orangeColor),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.14,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.08,
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
                                  height: height * 0.78,
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: TextField(
                                    maxLines: null, // 줄바꿈 허용

                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                    ),
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
                              onPressed: () {},
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
                  // Container(
                  //   decoration: BoxDecoration(color: Colors.black),
                  //   width: double.infinity,
                  //   height: inHeight * 0.06,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children: [
                  //       IconButton(
                  //         icon: Icon(Icons.arrow_back_ios),
                  //         onPressed: () {},
                  //       ),
                  //       IconButton(
                  //         icon: Icon(Icons.home, size: 36),
                  //         onPressed: () {},
                  //       ),
                  //       IconButton(
                  //         icon: Icon(Icons.arrow_forward_ios),
                  //         onPressed: () {},
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // ...existing code...
  }
}
