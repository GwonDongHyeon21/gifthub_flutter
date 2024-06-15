// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gifthub_flutter/login/login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class Settings extends StatelessWidget {
  const Settings({
    super.key,
    required this.accessToken,
    required this.roomId,
  });

  final String accessToken;
  final String roomId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('설정'),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final myRoomCode = await fetchMyRoomCode(roomId);
              if (myRoomCode != null) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '내 방 코드',
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          myRoomCode,
                          style: const TextStyle(fontSize: 14),
                        ),
                        IconButton(
                          onPressed: () {
                            _copyToClipboard(myRoomCode);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '코드가 복사되었습니다.',
                                  style: TextStyle(color: Colors.black),
                                ),
                                backgroundColor: Colors.white,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.content_copy, size: 12),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('방 코드를 가져오는 데 실패했습니다.'),
                    backgroundColor: Colors.white,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
            child: const Text('내가 만든 방 코드 보기'),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final users = await showUsers(roomId);
              if (users != null) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '현재 방 참여자',
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        children: users
                            .map((user) => ListTile(title: Text(user)))
                            .toList(),
                      ),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('방 참여자 정보를 가져오는 데 실패했습니다.'),
                    backgroundColor: Colors.white,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
            child: const Text('현재 방 참여자 보기'),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text(
                      '정말 방을 나가시겠습니까?',
                      style: TextStyle(fontSize: 18),
                    ),
                    actions: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('취소')),
                            TextButton(
                                onPressed: () => exitRoom(context, roomId),
                                child: const Text('확인')),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
              child: const Text('방 나가기'),
            )),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        '정말 탈퇴하시겠습니까?',
                        style: TextStyle(fontSize: 18),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('취소')),
                        TextButton(
                            onPressed: () => showOut(context),
                            child: const Text('확인')),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
              child: const Text('회원탈퇴'),
            )),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        '정말 로그아웃 하시겠습니까?',
                        style: TextStyle(fontSize: 18),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text('확인'),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
              child: const Text('로그아웃'),
            )),
      ]),
    );
  }

  Future<String?> fetchMyRoomCode(String roomId) async {
    final response = await http
        .get(Uri.parse('https://api.gifthub.site/room/$roomId/share'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<List<String>?> showUsers(String roomId) async {
    final response = await http
        .get(Uri.parse('https://api.gifthub.site/room/$roomId/users'));

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      final List<String> users =
          usersJson.map((user) => user.toString()).toList();
      return users;
    } else {
      return null;
    }
  }

  Future<void> exitRoom(BuildContext context, String roomId) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.gifthub.site/room/exit/$roomId'),
        headers: {
          'Authorization': accessToken,
        },
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      } else {
        print(response.statusCode);
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> showOut(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn();

      await googleSignIn.signOut();

      final account = await googleSignIn.signIn();

      if (account != null) {
        final googleAuth = await account.authentication;
        String providerAccessToken = googleAuth.accessToken!;

        final response = await http.delete(
          Uri.parse('https://api.gifthub.site/revoke'),
          headers: {
            'Authorization': accessToken,
          },
          body: {
            providerAccessToken,
          },
        );

        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        } else {
          print(response.statusCode);
        }
      }
    } catch (error) {
      print(error);
    }
  }
}

void _copyToClipboard(String roomCode) {
  Clipboard.setData(ClipboardData(text: roomCode));
}
