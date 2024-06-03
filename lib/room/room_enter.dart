// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gifthub_flutter/menu/menu_category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void showInputRoomCode(BuildContext context) {
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
              onPressed: () async {
                int statusNum = await enterRoom(roomCodeController.text);
                if (statusNum == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MenuCategory(
                              roomCode: roomCodeController.text,
                            )),
                  );
                }
                if (statusNum == 0) {
                  _showSnackBar(context);
                }
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

Future<int> enterRoom(String roomCode) async {
  final url = Uri.parse('https://api.gifthub.site/room/enter');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Authorization':
          'eyJhbGciOiJIUzI1NiJ9.eyJpZGVudGlmaWVyIjoiZ29vZ2xlMTA2MzIwODUzMTUxNzc4MDE5MzM5IiwiaWF0IjoxNzE2Mjk0MDM5LCJleHAiOjE3MTYyOTc2Mzl9.k3k39T3i434qQsxX-f7DH-PKr9Gq2k4kINYl6uOSg9k',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'code': roomCode,
    }),
  );

  if (response.statusCode == 200) {
    // 성공적으로 요청이 완료되었을 경우
    final responseData = jsonDecode(response.body);
    print('응답 데이터: $responseData');
    return 1;
  } else {
    // 요청 실패 시
    print('서버 요청 실패: ${response.statusCode}');
    return 0;
  }
}

void _showSnackBar(BuildContext context) {
  final snackBar = SnackBar(
    content: const Text(
      '없는 코드입니다.',
      style: TextStyle(color: Colors.black),
    ),
    backgroundColor: Colors.white,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  Future.delayed(const Duration(seconds: 2), () {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  });
}
