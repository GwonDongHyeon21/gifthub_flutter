// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gifthub_flutter/login/login.dart';
import 'package:gifthub_flutter/main.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Settings extends StatelessWidget {
  const Settings({super.key});

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
                final myRoomCode = await fetchMyRoomCode(2); // 방 ID 입력
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
                            style: const TextStyle(fontSize: 12),
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
                                  duration: Duration(seconds: 2),
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
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
              child: const Text('내가 만든 방 코드 보기'),
            )),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final users = await showUsers(2); // 방 ID 입력
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
                    duration: Duration(seconds: 3),
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
                      textAlign: TextAlign.center,
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
                                onPressed: () => exitRoom(2), // 방 ID 입력
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
                //실행
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
                _showLogoutDialog(context);
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

  Future<String?> fetchMyRoomCode(int roomId) async {
    final url = Uri.parse('https://api.gifthub.site/room/$roomId/share');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<List<String>?> showUsers(int roomId) async {
    final url = Uri.parse('https://api.gifthub.site/room/$roomId/users');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      final List<String> users =
          usersJson.map((user) => user.toString()).toList();
      return users;
    } else {
      return null;
    }
  }

  Future<bool> exitRoom(int roomId) async {
    final url = Uri.parse('https://api.gifthub.site/room/exit/$roomId');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Authorization':
            'eyJhbGciOiJIUzI1NiJ9.eyJpZGVudGlmaWVyIjoiZ29vZ2xlMTA2MzIwODUzMTUxNzc4MDE5MzM5IiwiaWF0IjoxNzE2OTIwMTYzLCJleHAiOjE3MTY5MjM3NjN9.JPSphiColOISnRQ3zP8hJuB53tNQkTLWQ3faDmBDPLA',
      },
    );

    if (response.statusCode == 200) {
      // 방 나가기 성공
      return true;
    } else {
      // 방 나가기 실패
      return false;
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('로그아웃 하시겠습니까?'),
              ],
            ),
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
                Provider.of<AuthProvider>(context, listen: false)
                    .setLoggedIn(false);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }
}

void _copyToClipboard(String roomCode) {
  Clipboard.setData(ClipboardData(text: roomCode));
}
