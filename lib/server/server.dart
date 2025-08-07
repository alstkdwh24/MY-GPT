import 'dart:io';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8085);
  print('Server running on http://${server.address.address}:${server.port}');

  await for (HttpRequest request in server) {
    if (request.uri.path == '/auth/kakao/callback') {
      final code = request.uri.queryParameters['code'];
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write('<h1>Kakao login success!</h1><p>Code: $code</p>');
      await request.response.close();
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not Fount');
      await request.response.close();
    }
  }
}
