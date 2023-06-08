import 'package:flutter/material.dart';

class SavesPage extends StatelessWidget {
  const SavesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved GIFs'),
      ),
      body: Center(
        child: const Text('List of saved GIFs goes here'),
      ),
    );
  }
}
