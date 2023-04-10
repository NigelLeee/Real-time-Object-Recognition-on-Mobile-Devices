import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class ImageMode extends StatefulWidget {
  @override
  ImageModeState createState() => ImageModeState();
}

class ImageModeState extends State<ImageMode> {
  File? image;
  List<dynamic> recogs =[];
  String className = "";
  String confidenceScore = "";
  final picker = ImagePicker();

  Future getImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });

      var recog = await Tflite.runModelOnImage(
        path: image!.path,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      setState(() {
        if(recog != null && recog.isNotEmpty) {
          recog!.forEach((resp) {
            className = "Object: " + resp["label"];
            confidenceScore = "Confidence: " + (resp["confidence"] as double).toStringAsFixed(2);
            return;
          });
        } else {
          className = "";
          confidenceScore = "";
        }
      });
    } 
  }   
  

  loadModel() async{
    await Tflite.loadModel(model: "assets/mobilenet_v1_1.0_224.tflite", labels: "assets/mobilenet_v1_1.0_224.txt");
  }

  runModel() async {
    if(image != null){
      var recog = await Tflite.runModelOnImage(
        path: image!.path,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      className = "";
      confidenceScore = "";
      recog!.forEach((resp) {
        className = "Object: " + resp["label"];
        confidenceScore = "Confidence: " + (resp["confidence"] as double).toStringAsFixed(2);
      });

      setState(() {
        className;
        confidenceScore;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 191, 172, 226),
      appBar: AppBar(
        title: const Text("Recognize objects through image"),
        backgroundColor: const Color.fromARGB(255, 62, 84, 172),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: image == null
                  ? const Text("No image selected")
                  : Image.file(image!),
            ),
          ),
          ElevatedButton(
            onPressed: getImage,
            child: const Text("Please select image"),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 62, 84, 172))),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    className,
                    style: const TextStyle(fontSize: 40),
                    ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        confidenceScore,
                        style: const TextStyle(fontSize: 40),
                      ),
                      SizedBox(height: 250),
                    ],
                  )
                );
              }
            ),
          )
        ],
      ),
    );
  }
}