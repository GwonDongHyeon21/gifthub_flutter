import 'package:flutter/material.dart';
import 'package:gifthub_flutter/login.dart';
import 'package:gifthub_flutter/main.dart';
import 'package:gifthub_flutter/menu_detail.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: MenuCategory(
        roomCode: '',
      ),
    ),
  ));
}

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
              onPressed: () {
                //실행
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
              onPressed: () {
                //실행
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
              child: const Text('현재 방 참여자 보기'),
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
