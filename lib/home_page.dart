import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ppu_feed/main.dart';
import 'package:ppu_feed/subscripions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Subscripions>> fetchSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    var res = await http.get(
      Uri.parse("http://feeds.ppu.edu/api/v1/subscriptions"),
      headers: {
        'Authorization': token,
      },
    );

    if (res.statusCode == 200) {
      print(token);
      var jsonArr = jsonDecode(res.body) as List;
      return jsonArr.map((e) => Subscripions.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch subscriptions: ${res.statusCode}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchSubscripions().then((onValue) {
    //   MainApp.subscripions = onValue;
    // });
    fetchSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "🌟 PPU Feeds 🌟",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
