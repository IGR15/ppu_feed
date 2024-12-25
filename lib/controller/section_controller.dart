import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ppu_feed/model/section.dart';
import 'package:ppu_feed/model/subscripions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SectionController {
  late Future<List<Section>> _sectionsFuture;
  final List<int> _subscribedSections = [];

  Future<List<Section>> fetchSections(int courseId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final res = await http.get(
      Uri.parse("http://feeds.ppu.edu/api/v1/courses/$courseId/sections"),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      var jsonArr = jsonDecode(res.body)['sections'] as List;
      return jsonArr.map((e) => Section.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load sections: ${res.statusCode}");
    }
  }

  Future<List<Subscripions>> fetchSubscribedSections() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final res = await http.get(
      Uri.parse("http://feeds.ppu.edu/api/v1/subscriptions"),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      var subscriptions = jsonDecode(res.body)['subscriptions'] as List;
      _subscribedSections.clear();
      for (var sub in subscriptions) {
        _subscribedSections.add(sub['section_id'] as int);
      }
      return subscriptions.map((e) => Subscripions.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch subscriptions: ${res.statusCode}");
    }
  }

  Future<int> subscribeToSection(int courseId, int sectionId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final url =
        "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/subscribe";

    final res = await http.post(
      Uri.parse(url),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      final jsonResponse = jsonDecode(res.body);
      _subscribedSections.add(sectionId);
      return jsonResponse['subscription_id'];
    } else {
      throw Exception("Failed to subscribe: ${res.statusCode}");
    }
  }

  void toggleSubscription(context, int courseId, int sectionId) async {
    if (_subscribedSections.contains(sectionId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Already subscribed to this section!")),
      );
      return;
    }

    try {
      await subscribeToSection(courseId, sectionId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Subscribed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<bool> isSubscribed(int sectionId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final res = await http.get(
      Uri.parse("http://feeds.ppu.edu/api/v1/subscriptions"),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      var subscriptions = jsonDecode(res.body)['subscriptions'] as List;
      return subscriptions.any((sub) => sub['section_id'] as int == sectionId);
    }
    return false;
  }

  Future<void> deleteSubscription(
      int courseId, int sectionId, int subcrioptinId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(token);
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }
    var res = await http.delete(
      Uri.parse(
          "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/subscribe/$subcrioptinId"),
      headers: {'Authorization': token},
    );
    if (res.statusCode == 200) {
      final jsonResponse = jsonDecode(res.body);
      _subscribedSections.remove(sectionId);
      return jsonResponse['subscription_id'];
    } else {
      throw Exception("Failed to unsubscribe: ${res.statusCode}");
    }
  }
}
