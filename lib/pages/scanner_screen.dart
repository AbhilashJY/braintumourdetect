import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Tumour Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BrainTumourDetection(),
    );
  }
}

class BrainTumourDetection extends StatefulWidget {
  const BrainTumourDetection({Key? key}) : super(key: key);

  @override
  _BrainTumourDetectionState createState() => _BrainTumourDetectionState();
}

class _BrainTumourDetectionState extends State
  with TickerProviderStateMixin {
  File? _imageFile;
  final picker = ImagePicker();
  String _prediction = '';

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> sendImageForPrediction(File imageFile) async {
    final url = Uri.parse('http://10.0.2.2:5000/predict');
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          _prediction = jsonResponse['class_name'];
        });
      } else {
        print('Failed to send image for prediction: ${response.statusCode}');
        // Handle error response if needed
      }
    } catch (e) {
      print('Error sending image for prediction: $e');
      // Handle any errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Tumour Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Upload the MRI image',
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: getImage,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.upload,
                  size: 50.0,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            _imageFile != null
                ? Column(
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: clearSelection,
                              child: Container(
                                  padding: const EdgeInsets.all(5),
                                  width: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Text("Clear",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                              )
                          ),
                          TextButton(
                              onPressed: () {
                                if (_imageFile != null) {
                                  sendImageForPrediction(_imageFile!);
                                } else {
                                  print('Please select an image first.');
                                }
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(5),
                                  width: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Text("TEST",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Container(
                        padding: const EdgeInsets.only(left: 15,right: 10,top: 5,bottom: 5),
                        width: 100,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                        ),
                        child: Text("Prediction: $_prediction"),
                      ),
                    ],
                  )
                : Container(),
            Container(
              child: const TextField(
                decoration: InputDecoration(
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clearSelection() {
    setState(() {
      _imageFile = null;
      _prediction = '';
    });
  }
}
