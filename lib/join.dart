import 'package:flutter/material.dart';
import 'package:flutter_gpt_project/domain.dart';
import 'package:http/http.dart' as http;

class Join extends StatefulWidget {
  const Join({super.key});

  @override
  State<Join> createState() => _JoinPageState();
}

class _JoinPageState extends State<Join> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final response = await http.post(
              Uri.parse('$domain/api/jwt/signUp'),
              headers: {'Content-Type': 'application/json'},
              body: {
                'email': 'user@example.com',
                'password': 'password123',
              },
            );
            // Handle join logic here
          },
          child: const Text('Join'),
        ),
      ),
    );
  }
}
