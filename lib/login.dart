// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gifthub_flutter/room.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const LoginPage());
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();

      if (account != null) {
        final googleAuth = await account.authentication;
        final accessToken = googleAuth.accessToken;

        // 서버에 토큰을 보내서 사용자 정보를 요청합니다.
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

          // 받은 토큰을 출력하거나 저장하는 로직을 추가할 수 있습니다.
          print('Authorization: $authorizationToken');
          print('ProviderAccessToken: $providerAccessToken');

          // 사용자 정보를 받아온 후에 다음 페이지로 이동하고 정보를 전달합니다.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Text(
                'GIFTHUB',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/gifthub.png',
                    height: 350,
                    width: 350,
                    fit: BoxFit.cover,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoomPage(
                        name: null,
                        email: null,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  fixedSize: const Size(350, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/apple_logo.png',
                      height: 30,
                      width: 30,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '애플 로그인',
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ElevatedButton(
                onPressed: () {
                  loginWithGoogle(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  fixedSize: const Size(350, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google_logo.png',
                      height: 30,
                      width: 30,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '구글 로그인',
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
