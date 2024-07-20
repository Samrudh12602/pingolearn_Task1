import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pingolearn/services/auth_service.dart';

class CommentsScreen extends StatefulWidget {
  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _maskEmail = false;
  List _comments = [];

  @override
  void initState() {
    super.initState();
    _fetchRemoteConfig();
    _fetchComments();
  }

  Future<void> _fetchRemoteConfig() async {
    await _remoteConfig.fetchAndActivate();
    setState(() {
      _maskEmail = _remoteConfig.getBool('mask_email');
    });
  }

  Future<void> _fetchComments() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/comments'));
    setState(() {
      _comments = json.decode(response.body);
    });
  }

  String _maskEmailString(String email) {
    if (_maskEmail) {
      final parts = email.split('@');
      final masked = parts[0].replaceRange(3, parts[0].length, '*' * (parts[0].length - 3));
      return '$masked@${parts[1]}';
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF0C54BE),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.white,
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
            },
          ),
        ],
      ),
      body: _comments.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _comments.length,
        itemBuilder: (context, index) {
          final comment = _comments[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFCED3DC),
                  child: Text(
                    comment['name'][0].toUpperCase(),
                    style: TextStyle(fontFamily: 'Poppins', color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                title: RichText(
                  text: TextSpan(
                    style: TextStyle(fontFamily: 'Poppins'),
                    children: <TextSpan>[
                      TextSpan(text: 'Name: ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                      TextSpan(text: comment['name'], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontFamily: 'Poppins'),
                        children: <TextSpan>[
                          TextSpan(text: 'Email: ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                          TextSpan(text: _maskEmailString(comment['email']), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      comment['body'],
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
