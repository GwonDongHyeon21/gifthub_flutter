// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gifthub_flutter/menu/ocr.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: MenuDetail(roomCode: '', title: ''),
    ),
  ));
}

class MenuDetail extends StatelessWidget {
  final String roomCode;
  final String title;

  const MenuDetail({Key? key, required this.roomCode, required this.title})
      : super(key: key);

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
            onPressed: () async {
              final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        content: SizedBox(
                          height: 550,
                          child: OCR(imagePath: pickedFile.path),
                        ));
                  },
                );
              }
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 25, top: 5),
              child: Row(children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                )
              ])),
          const Padding(
              padding: EdgeInsets.only(left: 15, top: 5),
              child: Row(children: [
                Text(
                  '유효기간 임박순입니다.',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )
              ])),
          Expanded(
            //
            // 카테고리에 해당하는 이미지들 불러오기
            //
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: 20, //전체 이미지수 count해서 삽입
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back), //폴더에 imgae 추가하여 삽입
                    label: Text('이미지 ${index + 1}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
