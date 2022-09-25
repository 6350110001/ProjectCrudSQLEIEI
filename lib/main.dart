import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Hide the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Upload Image to MySQL Server',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  XFile? pickedImage;
  ImagePicker _picker = ImagePicker();

  Future<void> uploadImage(filepath) async {
    String uploadUrl = 'http://10.0.2.2/android/upload_image_multipart.php';
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files
        .add(await http.MultipartFile.fromPath('uploadedfile', filepath));
    request.fields['name'] = 'test product multipart';
    request.fields['price'] = '599';
    request.fields['description'] = 'test product description multipart';
    var response = await request.send();
    if (response.statusCode == 200) {
      print("Upload successful-MultipartFile");
    } else {
      print("Error during connection to server-MultipartFile");
    }
  }

  Future<void> uploadImageBase64(imageFile) async {
    String uploadurl = "http://10.0.2.2/android/upload_image_base64.php";
    //convert file image to Base64 encoding
    String extension = p.extension(imageFile.path);
    String fileName = Uuid().v4() + extension;
    String baseimage = base64Encode(imageFile.readAsBytesSync());

    var response = await http.post(Uri.parse(uploadurl), body: {
      'image': baseimage,
      'filename': fileName,
      'name': 'test product base64',
      'price': '649',
      'description': 'test product description base64'
    });
    if (response.statusCode == 200) {
      print("Upload successful-Base64");
    } else {
      print("Error during connection to server-Base64");
    }
  }

  // Implementing the image picker
  Future<void> _openImagePicker() async {
    pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage!.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Upload Image File'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(35),
            child: Column(children: [
              Center(
                child: ElevatedButton(
                  child: const Text('Select An Image'),
                  onPressed: () {
                    _openImagePicker();
                  },
                ),
              ),
              const SizedBox(height: 35),
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 300,
                color: Colors.grey[300],
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : const Text('Please select an image'),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text('Upload Image (Base64)'),
                  onPressed: () {
                    //start uploading image
                    uploadImageBase64(_image);
                  },
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text('Upload Image (Multipart)'),
                  onPressed: () {
                    //start uploading image
                    uploadImage(pickedImage!.path);
                  },
                ),
              )
            ]),
          ),
        ));
  }
}
