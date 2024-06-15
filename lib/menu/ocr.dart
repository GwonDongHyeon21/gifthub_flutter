// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class OCR extends StatefulWidget {
  const OCR({
    Key? key,
    required this.accessToken,
    required this.roomId,
    required this.categoryId,
    required this.imagePath,
  }) : super(key: key);

  final String accessToken;
  final String roomId;
  final String categoryId;
  final String imagePath;

  @override
  _OCRState createState() => _OCRState();
}

class _OCRState extends State<OCR> {
  String parsedText = '';
  String parsedNumber = '';
  bool isParsing = true;

  parsethetext() async {
    var bytes = File(widget.imagePath).readAsBytesSync();
    String img64 = base64Encode(bytes);

    var post = await http.post(
      Uri.parse('https://api.ocr.space/parse/image'),
      body: {
        "base64Image": "data:image/jpg;base64,${img64.toString()}",
        "language": "kor"
      },
      headers: {"apikey": "K84813047988957"},
    );
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
        parsedText = extractedText;
      } else {
        parsedText = '';
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
                      : parsedText.isNotEmpty
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
                                "유효기간 : $parsedText",
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
                      : parsedText.isNotEmpty
                          ? ElevatedButton(
                              onPressed: () async {
                                await uploadImage(File(widget.imagePath),
                                    parsedNumber, parsedText);
                                Navigator.pop(context);
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

  Future<void> uploadImage(
      File imageFile, String barcode, String expireDate) async {
    var formattedBarcode = barcode.replaceAll(' ', '');
    var formattedExpireDate = expireDate
        .replaceAll('년 ', '-')
        .replaceAll('월 ', '-')
        .replaceAll('일', '');
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.gifthub.site/room/${widget.roomId}/categories/${widget.categoryId}'));
    request.headers['Authorization'] = widget.accessToken;
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path,
        contentType: MediaType('image', 'jpeg')));
    request.fields['imageOcrDTO'] = jsonEncode({
      "barcode": formattedBarcode,
      "expire": formattedExpireDate,
    });

    var res = await request.send();
    if (res.statusCode == 200) {
      print('Uploaded successfully');
    } else {
      print('Upload failed with status: ${res.statusCode}');
    }
  }
}
