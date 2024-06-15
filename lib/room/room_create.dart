// ignore_for_file: avoid_print, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gifthub_flutter/menu/menu_category.dart';
import 'package:http/http.dart' as http;

void showNewRoomCode(BuildContext context, String accessToken) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CreateRoomDialog(
        accessToken: accessToken,
      );
    },
  );
}

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({
    super.key,
    required this.accessToken,
  });

  final String accessToken;

  @override
  _CreateRoomDialogState createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final TextEditingController titleController = TextEditingController();
  String? roomId;
  bool isRoomCreated = false;

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
          if (roomId != null)
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
                      roomId!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    IconButton(
                      onPressed: () {
                        _copyToClipboard(roomId!);
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
              createRoom(titleController.text);
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

  Future<void> createRoom(String title) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.gifthub.site/room/create'),
        headers: {
          'Authorization': widget.accessToken,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "title": title,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final roomId = responseData['room_id'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuCategory(
              accessToken: widget.accessToken,
              roomId: roomId.toString(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '방 생성에 실패했습니다.',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
        print('방 생성 실패. 오류 코드: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
    }
  }
}
