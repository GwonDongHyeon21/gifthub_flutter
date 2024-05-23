// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gifthub_flutter/menu/menu_category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void _showNewRoomCode(BuildContext context, String roomCode) async {
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
                  roomCode,
                  style: const TextStyle(fontSize: 12),
                ),
                IconButton(
                  onPressed: () {
                    _copyToClipboard(roomCode);
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
                    builder: (context) => MenuCategory(roomCode: roomCode),
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

Future<void> handleCreateRoom(BuildContext context) async {
  String newRoomCode = await createRoom();
  if (newRoomCode.isNotEmpty) {
    _showNewRoomCode(context, newRoomCode);
  }
}

Future<String> createRoom() async {
  final url = Uri.parse('https://api.gifthub.site/room/create');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Authorization':
          'eyJhbGciOiJIUzI1NiJ9.eyJpZGVudGlmaWVyIjoiZ29vZ2xlMTA2MzIwODUzMTUxNzc4MDE5MzM5IiwiaWF0IjoxNzE2Mjk0MDM5LCJleHAiOjE3MTYyOTc2Mzl9.k3k39T3i434qQsxX-f7DH-PKr9Gq2k4kINYl6uOSg9k',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'title': '방제목입니다',
    }),
  );

  if (response.statusCode == 200) {
    // 방 생성 성공 시
    String responseData = jsonDecode(response.body);
    return responseData;
  } else {
    // 방 생성 실패 시
    print('방 생성 실패. 오류 코드: ${response.statusCode}');
    return '';
  }
}

void _copyToClipboard(String roomCode) {
  Clipboard.setData(ClipboardData(text: roomCode));
}
