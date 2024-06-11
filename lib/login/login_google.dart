// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gifthub_flutter/room/room.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

Future<void> loginWithGoogle(BuildContext context) async {
  try {
    final googleSignIn = GoogleSignIn();

    await googleSignIn.signOut();

    final account = await googleSignIn.signIn();

    if (account != null) {
      final googleAuth = await account.authentication;
      String? accessToken = googleAuth.accessToken;

      final response = await http.post(
        Uri.parse('https://api.gifthub.site/login/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "token": accessToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final accessToken = responseData['accessToken'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomPage(
              accessToken: accessToken,
            ),
          ),
        );
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
      }
    } else {
      print('Google sign-in cancelled');
    }
  } catch (error) {
    print("Error signing in with Google: $error");
  }
}
