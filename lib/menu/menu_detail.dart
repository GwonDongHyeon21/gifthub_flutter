// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gifthub_flutter/menu/ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: MenuDetail(
        roomId: '',
        categoryText: '',
        categoryId: '',
      ),
    ),
  ));
}

class MenuDetail extends StatefulWidget {
  final String roomId;
  final String categoryText;
  final String categoryId;

  const MenuDetail({
    Key? key,
    required this.roomId,
    required this.categoryText,
    required this.categoryId,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MenuDetailState createState() => _MenuDetailState();
}

class _MenuDetailState extends State<MenuDetail> {
  late List<String> imageUrls = [];
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
          imageUrls = data.map((item) => item['url']).cast<String>().toList();
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
                : imageUrls.isNotEmpty
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: imageUrls.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _showImageDialog(imageUrls[index]);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: AspectRatio(
                                aspectRatio: 3 / 12,
                                child: Image.network(
                                  imageUrls[index],
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

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swipe right, delete the image
                setState(() {
                  imageUrls.remove(imageUrl);
                });
                Navigator.of(context).pop();
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
}
