import 'package:flutter/material.dart';
import 'package:youtube_comment_analyzer/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.light(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        home: HomeScreen());
  }
}
