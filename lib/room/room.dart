// ignore_for_file: use_build_context_synchronously, avoid_print, must_be_immutable

import 'package:flutter/material.dart';
import 'package:gifthub_flutter/room/room_enter.dart';
import 'package:gifthub_flutter/room/room_create.dart';

class RoomPage extends StatelessWidget {
  RoomPage({
    super.key,
    required this.accessToken,
  });

  String? accessToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 150),
        child: Center(
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
                      showInputRoomCode(context, accessToken!);
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
                    showNewRoomCode(context, accessToken!);
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
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
