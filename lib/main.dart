import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),  
  );
}

late List<CameraDescription> cameras;

class MyApp extends StatefulWidget {
    const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CameraController cameraController;
  CameraImage? cameraImage;
  late List? recogList;
  bool isInterpreterBusy = false;
  final ObjectDetector objectDetector = ObjectDetector(options:ObjectDetectorOptions(mode:DetectionMode.stream, classifyObjects: true, multipleObjects: true));


  Future<void> initCamera() async {
    cameraController = CameraController(cameras[0], ResolutionPreset.low);
    await cameraController.initialize();
    cameraController.setExposureOffset(-3).then((value) {
      setState(() {
        cameraController.startImageStream((image) => {
            cameraImage = image,
            runModel(),
          });
      });
    });
  }

  Future<void> runModel() async {
    if (isInterpreterBusy) {
      print("Interpreter is busy, skipping model inference");
      return;
    }

    try {
      recogList = await Tflite.detectObjectOnFrame(
        bytesList: cameraImage!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        model: "SSDMobileNet",
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResultsPerClass: 1,
        threshold: 0.4,
      );
      
      setState(() { 
        cameraImage;
      });
    } catch (e) {
        print("Failed to run model: $e");
     }
    isInterpreterBusy = false;
  }

  Future<void> loadModel() async {
    Tflite.close();
    await Tflite.loadModel(model: "assets/ssd_mobilenet.tflite", labels: "assets/ssd_mobilenet.txt");
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.stopImageStream();
    Tflite.close();
  }

  @override
  void initState() {
    super.initState();

    loadModel(); 
    initCamera();  
  }

  List<Widget> _renderBoxes(Size screen) {
      return recogList!.map((re) {
        var _x = re["rect"]["x"];
        var _w = re["rect"]["w"];
        var _y = re["rect"]["y"];
        var _h = re["rect"]["h"];
        var scaleW, scaleH, x, y, w, h;
        double screenH = screen.height;
        double screenW = screen.width;
        int previewH = cameraImage!.height;
        int previewW = cameraImage!.width;


        if (screenH / screenW > previewH / previewW) {
          scaleW = screenH / previewH * previewW;
          scaleH = screenH;
          var difW = (scaleW - screenW) / scaleW;
          x = (_x - difW / 2) * scaleW;
          w = _w * scaleW;
          if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
          y = _y * scaleH;
          h = _h * scaleH;
        } else {
          scaleH = screenW / previewW * previewH;
          scaleW = screenW;
          var difH = (scaleH - screenH) / scaleH;
          x = _x * scaleW;
          w = _w * scaleW;
          y = (_y - difH / 2) * scaleH;
          h = _h * scaleH;
          if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
        }

        return Positioned(
          left: math.max(0, x),
          top: math.max(0, y),
          width: w,
          height: h,
          child: Container(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(37, 213, 253, 1.0),
                width: 3.0,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList();
  }

  @override  
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> list = [];

    list.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height - 100,
        child: SizedBox(
          height: size.height - 100,
          child: (!cameraController.value.isInitialized)
              ? Container()
              :AspectRatio(aspectRatio: cameraController.value.aspectRatio, child: CameraPreview(cameraController),
              ),
        ),
      ),
    );

    if (cameraImage != null) {
      list.addAll(_renderBoxes(size));
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          margin: const EdgeInsets.only(top: 50),
          color: Colors.black,
          child: Stack(
            children: list,
          ),
        ),
      ),
    );
  }
  
}
 