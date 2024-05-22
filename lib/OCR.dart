// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OCR extends StatefulWidget {
  final String imagePath;

  const OCR({Key? key, required this.imagePath}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OCRState createState() => _OCRState();
}

class _OCRState extends State<OCR> {
  String parsedtext = '';
  String parsedNumber = '';
  bool isParsing = true;

  parsethetext() async {
    var bytes = File(widget.imagePath).readAsBytesSync();
    String img64 = base64Encode(bytes);

    var url = 'https://api.ocr.space/parse/image';
    var payload = {
      "base64Image": "data:image/jpg;base64,${img64.toString()}",
      "language": "kor"
    };
    var header = {"apikey": "K84813047988957"};

    var post = await http.post(Uri.parse(url), body: payload, headers: header);
    var result = jsonDecode(post.body);

    setState(() {
      RegExp numberRegExp = RegExp(r'\d{4} \d{4} \d{4}');
      var extractedNumber =
          numberRegExp.stringMatch(result['ParsedResults'][0]['ParsedText']);
      if (extractedNumber != null) {
        parsedNumber = extractedNumber;
      } else {
        parsedNumber = '';
      }
      RegExp dataRegExp = RegExp(r'\d{4}년 \d{2}월 \d{2}일');
      var extractedText =
          dataRegExp.stringMatch(result['ParsedResults'][0]['ParsedText']);
      if (extractedText != null) {
        parsedtext = extractedText;
      } else {
        parsedtext = '';
      }
      isParsing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    parsethetext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close_outlined),
                ),
              ],
            ),
            SizedBox(
              height: 300,
              child: ClipRect(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(widget.imagePath)),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  isParsing
                      ? Column(children: [
                          const SizedBox(
                            height: 76,
                          ),
                          Text(
                            '텍스트를 추출하는 중입니다...',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.5)),
                          )
                        ])
                      : parsedtext.isNotEmpty
                          ? Column(children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "바코드 : $parsedNumber",
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "유효기간 : $parsedtext",
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                '이 기프티콘을 등록하시겠습니까?',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withOpacity(0.5)),
                              )
                            ])
                          : const Text('텍스트 추출에 실패했습니다.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              )),
                  const SizedBox(
                    height: 20,
                  ),
                  isParsing
                      ? ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.grey.withOpacity(0.5)),
                          child: const Text('텍스트 추출 중...'))
                      : parsedtext.isNotEmpty
                          ? ElevatedButton(
                              onPressed: () {
                                //데이터베이스에 등록(바코드, 유효기간)
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: const Color(0xFFDBD6F3)),
                              child: const Text('네 등록할래요!'))
                          : ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor:
                                      Colors.grey.withOpacity(0.5)),
                              child: const Text('텍스트 추출 실패')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
