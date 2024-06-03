import 'package:flutter/material.dart';
import 'package:gifthub_flutter/menu/menu_detail.dart';
import 'package:gifthub_flutter/room/room_settings.dart';

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: MenuCategory(
        roomCode: '',
      ),
    ),
  ));
}

/*
Future<List<dynamic>> fetchCategories(int roomId) async {
  final url = Uri.parse('https://api.gifthub.site/room/main/$roomId');

  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'eyJhbGciOiJIUzI1NiJ9.eyJpZGVudGlmaWVyIjoiYXBwbGUwMDE5MTQuNWFjN2ExODgyZmMzNGM5ODlmNWM5NjNhZGEzYmIwNzcuMTQwMCIsImlhdCI6MTcxNjkxODYzMiwiZXhwIjoxNzE2OTIyMjMyfQ.70zbeysGO0Gfo94PyPDhw-p96ff2S69kRlUuGrw4YhE',
  };

  try {
    final response = await http.get(url, headers: headers);
    final utf8Body = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8Body);
      if (decoded is List) {
        return decoded;
      } else {
        throw Exception('Expected a list but got ${decoded.runtimeType}');
      }
    } else {
      throw Exception('Failed to load categories');
    }
  } catch (e) {
    throw Exception('Failed to load categories: $e');
  }
}
*/

class MenuCategory extends StatelessWidget {
  const MenuCategory({Key? key, required this.roomCode}) : super(key: key);

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                MaterialPageRoute(builder: (context) => const Settings()),
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
                roomCode, // roomCode에 해당하는 방제목 가져오기
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ))),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildCategoryButton(context, '치킨:피자:햄버거'),
                _buildCategoryButton(context, '카페:베이커리'),
                _buildCategoryButton(context, '아이스크림:빙수'),
                _buildCategoryButton(context, '영화관:테마파크'),
                _buildCategoryButton(context, '중식:일식'),
                _buildCategoryButton(context, '족발:보쌈:고기'),
                _buildCategoryButton(context, '상품권'),
                _buildCategoryButton(context, '기타'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String category) {
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
                      builder: (context) =>
                          MenuDetail(roomCode: roomCode, title: categoryText),
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
