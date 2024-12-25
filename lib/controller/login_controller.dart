import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ppu_feed/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginController{
  final String loginUrl = "http://feeds.ppu.edu/api/login";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  

  Future<void> login(context,String Email,String password) async {
    try {
      http.Response response = await http.post(Uri.parse(loginUrl),
          body: json.encode({
            'email': Email,
            'password': password
          }));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        print(response.body);
        dynamic jsonObject = jsonDecode(response.body);
        print(jsonObject['status']);
        if (jsonObject['status'] == 'success') {
        
          
         User user =  User(token: jsonObject['session_token'],username: jsonObject["username"]);
          final SharedPreferences? prefs = await _prefs;

          await prefs?.setString('token', user.token);
          await prefs?.setString('username', user.username);
          Navigator.pushReplacementNamed(context, "/home_page");
        }

      }
    } catch (error) {
      print("Error: $error");
    }
  }











}