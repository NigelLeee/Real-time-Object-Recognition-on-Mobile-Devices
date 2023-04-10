import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'firebase_helper.dart';
import 'main.dart';
import 'package:tflite/tflite.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

class ModelFromFirebase extends StatefulWidget {
  const ModelFromFirebase({Key? key}) : super(key: key);

  @override
  ModelFromFirebaseState createState() => ModelFromFirebaseState();
}

class ModelFromFirebaseState extends State<ModelFromFirebase> {
  bool cameraIsWorking = false;
  String res = "";
  late CameraController cameraController;
  late CameraImage? cameraImage = initCamera();

  loadModel() async{
    
    await Tflite.loadModel(model: localModelPath.toString(), labels: "assets/mobilenet_v1_1.0_224.txt");
  }

  initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.low);
    cameraController.initialize().then((value) {
      if(!mounted){
        return;
      }
      setState(() {
        cameraController.startImageStream((image) => {
          if(!cameraIsWorking){
            cameraIsWorking = true,
            cameraImage = image,
            runModel(),
          }
        });
      });
    });
  }

  runModel() async{
    if(cameraImage != null){
      var recogList = await Tflite.runModelOnFrame(bytesList: cameraImage!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      res = "";

      recogList!.forEach((resp) {
        // ignore: prefer_interpolation_to_compose_strings
        res += "Object: " + resp["label"] + "\nConfidence: " + (resp["confidence"] as double).toStringAsFixed(2) + "\n\n";
       });

       setState(() {
         res;
       });

       cameraIsWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();

    loadModel();
  }

  @override
  void dispose() async{
    super.dispose();

    await Tflite.close();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 101, 93, 187),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: Container(
                        color: const Color.fromARGB(255, 62, 84, 172),
                        height: 360,
                        width: 600,
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: (){
                          initCamera();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 35),
                          height: 310,
                          width: 600,
                          child: cameraImage == null
                            ? Container(
                              height: 200,
                              width: 600,
                              child: const Icon(Icons.photo_camera_front, color: Colors.blueAccent, size: 60,),
                            )
                            : AspectRatio(
                              aspectRatio: cameraController.value.aspectRatio,
                              child: CameraPreview(cameraController),
                            ),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 55.0),
                    child: SingleChildScrollView(
                      child: Text(
                        res,
                        style: const TextStyle(
                          backgroundColor: Color.fromARGB(255, 191, 172, 226),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}