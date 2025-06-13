import 'package:flutter/material.dart';

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
          onPressed: () {
            // Handle join logic here
          },
          child: const Text('Join'),
        ),
      ),
    );
  }
}
