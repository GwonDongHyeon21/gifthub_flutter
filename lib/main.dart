// ignore_for_file: library_private_types_in_public_api, avoid_print, unnecessary_null_comparison, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gifthub_flutter/menu/menu_category.dart';
import 'package:gifthub_flutter/room/room.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gifthub_flutter/login/login.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? account;
  bool _isLoading = true;
  String roomId = '';
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    try {
      final user = await _googleSignIn.signInSilently();
      if (user != null) {
        final auth = await user.authentication;
        accessToken = auth.accessToken;
        if (accessToken != null) {
          await setUp(accessToken!);
          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (accessToken != null && roomId != null) {
      return MenuCategory(
        accessToken: accessToken!,
        roomId: roomId,
      );
    } else if (accessToken != null && roomId == null) {
      return RoomPage(
        accessToken: accessToken,
      );
    } else {
      return const LoginPage();
    }
  }

  Future<void> setUp(String accessToken) async {
    final response = await http.post(
      Uri.parse('https://api.gifthub.site/login/google'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "token": accessToken,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        roomId = responseData['room_id'].toString();
      });
    } else {
      print('Failed to log in with Google: ${response.body}');
    }
  }
}
