// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gifthub_flutter/room/room.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

Future<void> loginWithGoogle(BuildContext context) async {
  try {
    final googleSignIn = GoogleSignIn();
    final account = await googleSignIn.signIn();

    if (account != null) {
      final googleAuth = await account.authentication;
      final accessToken = googleAuth.accessToken;

      final response = await http.post(
        Uri.parse('https://api.gifthub.site/login/google'),
        body: json.encode({
          'token': accessToken,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        final authorizationToken = userData['Authorization'];
        final providerAccessToken = userData['ProviderAccessToken'];

        print('Authorization: $authorizationToken');
        print('ProviderAccessToken: $providerAccessToken');

        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomPage(
              name: userData['name'],
              email: userData['email'],
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
