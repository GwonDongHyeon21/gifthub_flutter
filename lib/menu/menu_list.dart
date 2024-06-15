// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gifthub_flutter/menu/ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class MenuDetail extends StatefulWidget {
  const MenuDetail({
    Key? key,
    required this.accessToken,
    required this.roomId,
    required this.categoryText,
    required this.categoryId,
  }) : super(key: key);

  final String accessToken;
  final String roomId;
  final String categoryText;
  final String categoryId;

  @override
  // ignore: library_private_types_in_public_api
  _MenuDetailState createState() => _MenuDetailState();
}

class _MenuDetailState extends State<MenuDetail> {
  late List<Map<String, dynamic>> images = [];
  bool isLoading = false;
  String? selectedImageUrl;

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://api.gifthub.site/room/${widget.roomId}/categories/${widget.categoryId}'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          images = data
              .map((item) => {
                    'url': item['url'],
                    'id': item['id'],
                  })
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load images: $e');
    }
  }

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
                          child: OCR(
                            accessToken: widget.accessToken,
                            roomId: widget.roomId,
                            categoryId: widget.categoryId,
                            imagePath: pickedFile.path,
                          ),
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
            child: Row(
              children: [
                Text(
                  widget.categoryText,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 15, top: 5),
            child: Row(
              children: [
                Text(
                  '유효기간 임박순입니다.',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : images.isNotEmpty
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: images.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _showImageDialog(
                                    images[index]['url'], images[index]['id']);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: AspectRatio(
                                aspectRatio: 3 / 12,
                                child: Image.network(
                                  images[index]['url']!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text('No images found'),
                      ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl, String imageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('정말 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('취소')),
                        TextButton(
                            onPressed: () => deleteImage(
                                widget.roomId, widget.categoryId, imageId),
                            child: const Text('확인')),
                      ],
                    );
                  },
                );
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteImage(
      String roomId, String categoryId, String gifticonId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://api.gifthub.site/room/$roomId/categories/$categoryId/gifticons/$gifticonId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '삭제되었습니다.',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print(response.statusCode);
      }
    } catch (error) {
      print(error);
    }
  }
}
