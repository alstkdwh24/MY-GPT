import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LicenseLinks extends StatelessWidget {
  const LicenseLinks({super.key});

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText.rich(
        TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(text: 'Email icons created by Fathema Khanom - '),
            TextSpan(
              text: 'Flaticon\n',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () => _launch(
                          'https://www.flaticon.com/free-icons/email',
                        ),
            ),
            TextSpan(text: 'Login icons created by Freepik - '),
            TextSpan(
              text: 'Flaticon\n',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () => _launch(
                          'https://www.flaticon.com/free-icons/login',
                        ),
            ),
            TextSpan(text: 'Login icons created by Uniconlabs - '),
            TextSpan(
              text: 'Flaticon\n',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () => _launch(
                          'https://www.flaticon.com/free-icons/login',
                        ),
            ),
            TextSpan(text: 'Kakao talk icons created by Fathema Khanom - '),
            TextSpan(
              text: 'Flaticon\n',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () => _launch(
                          'https://www.flaticon.com/free-icons/kakao-talk',
                        ),
            ),
            TextSpan(text: 'Kakao talk icons created by Fathema Khanom - '),
            TextSpan(
              text: 'Flaticon\n',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () => _launch(
                          'https://www.flaticon.com/free-icons/kakao-talk',
                        ),
            ),
            TextSpan(text: 'Letter n icons created by riajulislam - '),
            TextSpan(
              text: 'Flaticon\n',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () => _launch(
                          'https://www.flaticon.com/free-icons/letter-n',
                        ),
            ),
            TextSpan(text: 'Google icons created by Freepik - '),
            TextSpan(
              text: 'Flaticon\n',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () => _launch(
                          'https://www.flaticon.com/free-icons/google',
                        ),
            ),
            TextSpan(text: 'Mac icons created by Hight Quality Icons - '),
            TextSpan(
              text: 'Flaticon\n',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () =>
                            _launch('https://www.flaticon.com/free-icons/mac'),
            ),
            TextSpan(text: 'Google icons created by Alfredo Creates - '),
            TextSpan(
              text: 'Flaticon\n',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () => _launch(
                          'https://www.flaticon.com/free-icons/google',
                        ),
            ),
            TextSpan(text: 'Button icons created by Freepik - '),
            TextSpan(
              text: 'Flaticon',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () => _launch(
                          'https://www.flaticon.com/free-icons/button',
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
