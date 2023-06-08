import 'package:flutter/material.dart';
import 'package:flutterfunmemes/card.dart';
import 'package:flutterfunmemes/save.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Fun Memes',
      home: Scaffold(
        appBar: AppBar(title: const Text('GIF`s Detective by OD')),
        bottomNavigationBar: BottomAppBar(
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            child: const Icon(Icons.save),
            onPressed: () {
              // Handle home button pressed
            },
          ),
        ),
        body: const GifSearchWidget(),
      ),
    );
  }
}
