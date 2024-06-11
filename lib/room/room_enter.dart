// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gifthub_flutter/menu/menu_category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void showInputRoomCode(BuildContext context, String accessToken) {
  final TextEditingController roomCode = TextEditingController();

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
              controller: roomCode,
              decoration:
                  const InputDecoration(hintText: '참여하려는 방의 코드를 입력해주세요'),
            ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
              onPressed: () {
                enterRoom(context, roomCode.text, accessToken);
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

Future<void> enterRoom(
    BuildContext context, String roomCode, String accessToken) async {
  try {
    final url = Uri.parse('https://api.gifthub.site/room/enter');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': accessToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'code': roomCode,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      final roomId = responseData;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuCategory(roomId: roomId.toString()),
        ),
      );
    } else {
      _showSnackBar(context);
      print('방 입장 실패. 오류 코드: ${response.statusCode}');
    }
  } catch (error) {
    print(error);
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
