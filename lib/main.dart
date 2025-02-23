import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HTTP API Checker',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          primaryColor: Colors.blue,
        ),
        home: const HomeWidget(),
      );
}

class Post {
  final String userId;
  final String title;
  final String description;

  Post({
    required this.userId,
    required this.title,
    required this.description,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        userId: json['userId'],
        title: json['title'],
        description: json['body'],
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'title': title,
        'body': description,
      };
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _responseBody = '';
  String _statusCode = '';
  bool _isLoading = false;

  Future<void> _checkApi(String method) async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse(_urlController.text);
      http.Response response;

      if (method == 'GET') {
        response = await http.get(uri);
      } else {
        final post = Post(
          userId: _userIdController.text,
          title: _titleController.text,
          description: _descriptionController.text,
        );
        final body = jsonEncode(post.toJson());
        final headers = {'Content-Type': 'application/json'};

        if (method == 'POST') {
          response = await http.post(uri, headers: headers, body: body);
        } else if (method == 'PUT') {
          response = await http.put(uri, headers: headers, body: body);
        } else {
          response = await http.delete(uri);
        }
      }

      setState(() {
        _statusCode = 'Status Code: ${response.statusCode}';
        _responseBody = response.body;
      });
    } catch (e) {
      setState(() {
        _statusCode = 'Error';
        _responseBody = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('RESTful API Checker')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Enter API URL',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _checkApi('GET'),
                    child: const Text('GET'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _checkApi('POST'),
                    child: const Text('POST'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _checkApi('PUT'),
                    child: const Text('PUT'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _checkApi('DELETE'),
                    child: const Text('DELETE'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _statusCode,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _responseBody,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    _urlController.dispose();
    _userIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  
}