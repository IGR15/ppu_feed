import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ppu_feed/modules/section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CourseFeedScreen extends StatefulWidget {
  final int courseId;
  const CourseFeedScreen({super.key, required this.courseId});

  @override
  _CourseFeedScreenState createState() => _CourseFeedScreenState();
}

class _CourseFeedScreenState extends State<CourseFeedScreen> {
  late Future<List<Section>> _sectionsFuture;
  final List<int> _subscribedSections = [];

  @override
  void initState() {
    super.initState();
    _sectionsFuture = fetchSections();
    fetchSubscribedSections();
  }

  Future<List<Section>> fetchSections() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final res = await http.get(
      Uri.parse(
          "http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections"),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      var jsonArr = jsonDecode(res.body)['sections'] as List;
      return jsonArr.map((e) => Section.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load sections: ${res.statusCode}");
    }
  }

  Future<void> fetchSubscribedSections() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final res = await http.get(
      Uri.parse("http://feeds.ppu.edu/api/v1/subscriptions"),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      var subscriptions = jsonDecode(res.body)['subscriptions'] as List;
      setState(() {
        _subscribedSections.addAll(
          subscriptions.map((sub) => sub['section_id'] as int),
        );
      });
    } else {
      throw Exception("Failed to fetch subscriptions: ${res.statusCode}");
    }
  }

  Future<int> subscribeToSection(int sectionId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final url =
        "http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/$sectionId/subscribe";

    final res = await http.post(
      Uri.parse(url),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      final jsonResponse = jsonDecode(res.body);
      return jsonResponse['subscription_id'];
    } else {
      throw Exception("Failed to subscribe: ${res.statusCode}");
    }
  }

  void toggleSubscription(int sectionId) async {
    if (_subscribedSections.contains(sectionId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Already subscribed to this section!")),
      );
      return;
    }

    try {
      await subscribeToSection(sectionId);
      setState(() {
        _subscribedSections.add(sectionId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Subscribed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Feed"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Section>>(
        future: _sectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final sections = snapshot.data!;
            return ListView.builder(
              itemCount: sections.length,
              itemBuilder: (context, index) {
                Section section = sections[index];
                bool isSubscribed = _subscribedSections.contains(section.id);

                return Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[300],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text(section.name),
                      subtitle: Text("Lecturer : ${section.lecturer}"),
                      trailing: IconButton(
                        onPressed: () => toggleSubscription(section.id),
                        icon: Icon(
                          isSubscribed ? Icons.check : Icons.add,
                          color:
                              isSubscribed ? Colors.green[800] : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No sections available."));
          }
        },
      ),
    );
  }
}
