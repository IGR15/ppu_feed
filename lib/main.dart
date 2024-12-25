import 'package:flutter/material.dart';
import 'package:ppu_feed/home_page.dart';
import 'package:ppu_feed/login_page.dart';
import 'package:ppu_feed/model/subscripions.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  static List<Subscripions> subscripions = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "flutter demo",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login_page',
      routes: {
        '/login_page': (context) => LoginPage(),
        '/home_page': (context) => HomePage(),
      },
    );
  }
}
