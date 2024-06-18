// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gifthub_flutter/menu/menu_list.dart';
import 'package:gifthub_flutter/room/room_settings.dart';
import 'package:http/http.dart' as http;

class MenuCategory extends StatefulWidget {
  const MenuCategory({
    Key? key,
    required this.accessToken,
    required this.roomId,
  }) : super(key: key);

  final String accessToken;
  final String roomId;

  @override
  _MenuCategoryState createState() => _MenuCategoryState();
}

class _MenuCategoryState extends State<MenuCategory> {
  String? roomTitle;

  @override
  void initState() {
    super.initState();
    _fetchRoomTitle();
  }

  Future<void> _fetchRoomTitle() async {
    try {
      final response = await http.get(
          Uri.parse('https://api.gifthub.site/room/main/${widget.roomId}'));

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          roomTitle = responseData['title'];
        });
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Settings(
                      accessToken: widget.accessToken,
                      roomId: widget.roomId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Text(
                  roomTitle ?? '',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  _buildCategoryButton(context, '치킨:피자:햄버거', '1'),
                  _buildCategoryButton(context, '카페:베이커리', '2'),
                  _buildCategoryButton(context, '아이스크림:빙수', '3'),
                  _buildCategoryButton(context, '영화관:테마파크', '4'),
                  _buildCategoryButton(context, '중식:일식', '5'),
                  _buildCategoryButton(context, '족발:보쌈:고기', '6'),
                  _buildCategoryButton(context, '상품권', '7'),
                  _buildCategoryButton(context, '기타', '8'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
      BuildContext context, String category, String categoryId) {
    var imagePath = 'assets/images/$category.png';
    var categoryText = category.replaceAll(':', '/');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuDetail(
                        accessToken: widget.accessToken,
                        roomId: widget.roomId,
                        categoryText: categoryText,
                        categoryId: categoryId,
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            categoryText,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
