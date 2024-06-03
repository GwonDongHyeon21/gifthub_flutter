// ignore_for_file: avoid_print, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gifthub_flutter/menu/menu_category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void showNewRoomCode(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const CreateRoomDialog();
    },
  );
}

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({super.key});

  @override
  _CreateRoomDialogState createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final TextEditingController titleController = TextEditingController();
  String? roomCode;
  bool isRoomCreated = false;

  void createRoom() async {
    final newRoomCode = await _createRoom(titleController.text);
    if (newRoomCode.isNotEmpty) {
      setState(() {
        roomCode = newRoomCode;
        isRoomCreated = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방 생성에 실패했습니다.', style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<String> _createRoom(String title) async {
    final url = Uri.parse('https://api.gifthub.site/room/create');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Authorization':
            'eyJhbGciOiJIUzI1NiJ9.eyJpZGVudGlmaWVyIjoiZ29vZ2xlMTA2MzIwODUzMTUxNzc4MDE5MzM5IiwiaWF0IjoxNzE2Mjk0MDM5LCJleHAiOjE3MTYyOTc2Mzl9.k3k39T3i434qQsxX-f7DH-PKr9Gq2k4kINYl6uOSg9k',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'title': title,
      }),
    );

    if (response.statusCode == 200) {
      // 방 생성 성공 시
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['roomCode'];
    } else {
      // 방 생성 실패 시
      print('방 생성 실패. 오류 코드: ${response.statusCode}');
      return '';
    }
  }

  void _copyToClipboard(String roomCode) {
    Clipboard.setData(ClipboardData(text: roomCode));
  }

  @override
  Widget build(BuildContext context) {
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
          if (roomCode != null)
            Column(
              children: [
                const Text(
                  '코드를 친구나 가족에게 공유하세요',
                  style: TextStyle(fontSize: 12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      roomCode!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    IconButton(
                      onPressed: () {
                        _copyToClipboard(roomCode!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('코드가 복사되었습니다.'),
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
              ],
            ),
          const SizedBox(
            height: 8,
          ),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: '방 제목을 입력해주세요'),
          ),
          const SizedBox(
            height: 8,
          ),
          ElevatedButton(
            onPressed: () {
              if (isRoomCreated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuCategory(roomCode: roomCode!),
                  ),
                );
              } else {
                createRoom();
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFFDBD6F3),
            ),
            child: Text(isRoomCreated ? '완료' : '제작'),
          ),
        ],
      ),
    );
  }
}
