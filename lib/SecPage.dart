import 'package:flutter/material.dart';
import 'firebase_helper.dart';
import 'VideoMode.dart';
import 'ImageMode.dart';
import 'ModelFromFirebase.dart';

class SecPage extends StatefulWidget {
  const SecPage({Key? key}) : super(key: key);

  @override
  SecState createState() => SecState();
}

class SecState extends State<SecPage> { 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 191, 172, 226),
      appBar: AppBar(
        title: const Text("Mode Selection"),
        backgroundColor: const Color.fromARGB(255, 62, 84, 172),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:  MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text("Video Stream"),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 62, 84, 172))),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const VideoMode())
                );
              },
            ),
            ElevatedButton(
              child: const Text("Video Stream (From Firbase)"),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 62, 84, 172))),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ModelFromFirebase())
                );
              },
            ),
            ElevatedButton(
              child: const Text("Download Model From Firebase"),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 62, 84, 172))),
              onPressed: getModelFromFirebase,
            ),
            ElevatedButton(
              child: Text("Image Upload"),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 62, 84, 172))),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ImageMode())
                );
              },
            )
          ],
        ),
      ),
    );
  }
}