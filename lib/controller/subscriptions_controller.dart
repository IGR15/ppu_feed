import 'dart:convert';

import 'package:ppu_feed/model/subscripions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SubscriptionsController {
  Future<List<Subscripions>> fetchSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(token);

    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    var res = await http.get(
      Uri.parse("http://feeds.ppu.edu/api/v1/subscriptions"),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      print(res.body);
      var jsonArr = jsonDecode(res.body)['subscriptions'] as List;
      return jsonArr.map((e) => Subscripions.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch subscriptions: ${res.statusCode}");
    }
  } 
  
}