// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gifthub_flutter/menu_category.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RoomPage(
    name: null,
    email: null,
  ));
}

class RoomPage extends StatelessWidget {
  const RoomPage({super.key, required email, required name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            const Text(
              '현재 참여중인 방이 없습니다.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              '방을 참여하거나 새로 개설해주세요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Image.asset(
                'assets/images/room.png',
                width: 350,
                height: 350,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ElevatedButton(
                  onPressed: () {
                    _showInputRoomCode(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 70),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFF45B6E8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '방에 참여하기',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '이미 누군가가 방을 만들었다면 방에 들어가요',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: ElevatedButton(
                  onPressed: () {
                    _showNewRoomCode(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 70),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFDBD6F3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                  ),
                  child: const Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '방 만들기',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '내가 제일먼저 방을 만들어 보아요',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  void _showInputRoomCode(BuildContext context) {
    final TextEditingController roomCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text(
                  '방에 참여하기',
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ]),
              const SizedBox(
                height: 8,
              ),
              TextField(
                controller: roomCodeController,
                decoration:
                    const InputDecoration(hintText: '참여하려는 방의 코드를 입력해주세요'),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MenuCategory(roomCode: roomCodeController.text)),
                  );
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFDBD6F3)),
                child: const Text('참여'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNewRoomCode(BuildContext context) async {
    String newRoomCode = await createRoom(); // 방 생성 통신 실행

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '방 만들기',
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
              const Text(
                '코드를 친구나 가족에게 공유하세요',
                style: TextStyle(fontSize: 12),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    newRoomCode, // 생성된 방 코드 표시
                    style: const TextStyle(fontSize: 12),
                  ),
                  IconButton(
                    onPressed: () {
                      _copyToClipboard(newRoomCode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('코드가 복사되었습니다.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.content_copy, size: 12),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              const TextField(
                decoration: InputDecoration(hintText: '방 제목을 입력해주세요'),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuCategory(roomCode: newRoomCode),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xFFDBD6F3),
                ),
                child: const Text('제작'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> createRoom() async {
    String url = 'https://api.gifthub.site/room/create';
    Map<String, String> headers = {
      'Authorization':
          'eyJhbGciOiJIUzI1NiJ9.eyJpZGVudGlmaWVyIjoiZ29vZ2xlMTA2MzIwODUzMTUxNzc4MDE5MzM5IiwiaWF0IjoxNzE2Mjk0MDM5LCJleHAiOjE3MTYyOTc2Mzl9.k3k39T3i434qQsxX-f7DH-PKr9Gq2k4kINYl6uOSg9k',
      'Content-Type': 'application/json',
    };
    Map<String, String> body = {'title': '방제목입니다'};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // 방 생성 성공 시
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String roomCode = responseData['roomCode'];
        return roomCode;
      } else {
        // 방 생성 실패 시
        print('방 생성 실패. 오류 코드: ${response.statusCode}');
        return ''; // 실패 시 빈 문자열 반환
      }
    } catch (e) {
      // 네트워크 오류 처리
      print('네트워크 오류: $e');
      return ''; // 오류 시 빈 문자열 반환
    }
  }
}

void _copyToClipboard(String roomCode) {
  Clipboard.setData(ClipboardData(text: roomCode));
}
