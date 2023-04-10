import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' as typed;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),  
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Object Recognition Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();
  File? _imageFile;
  String _result = '';
  String? accessToken = '';
  late String? _authorizationCode;
  late final inputTensor;
  GoogleSignIn googleSignIn = GoogleSignIn();
  final String ENDPOINT_ID = '3680338097049960448';
  final String PROJECT_ID = 'fyprealtimeobjectrecognition';
  final String INPUT_DATA_FILE = 'INPUT-JSON';
  
  
  Future getImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future recognizeImage() async {
    if (_imageFile == null) {
      setState(() {
        _result = 'Please select an image first';
      });
      return;
    }
  }  

  
  void _detectObjects() async {
    if (_imageFile == null) return;
    final imageBytes = await _imageFile!.readAsBytes();
    Uint8List uint8list = Uint8List.fromList(imageBytes);
    img.Image? image = img.decodeImage(uint8list);
    img.Image resizedImage = img.copyResize(image!, width: 1216, height: 800);
    typed.Uint8List resizedBytes = resizedImage.getBytes();
    List<int> resizedIntList = resizedBytes.buffer.asInt8List();
    Float32List inputList = Float32List.fromList(resizedIntList.map((e) => e / 255.0).toList());
    var inputShape = [1, 3, 800, 1216];
    var inputArray = Float32List(inputShape.reduce((a, b) => a * b));
    var offset = 0;
    for (var row = 0; row < 800; row++) {
      for (var col = 0; col < 1216; col++) {
        var idx = row * 1216 + col;
        inputArray[offset] = inputList[idx * 3];
        inputArray[offset + 1] = inputList[idx * 3 + 1];
        inputArray[offset + 2] = inputList[idx * 3 + 2];
        offset += 3;
      }
  }
    accessToken = await getAccessToken();
    final response = await detectObjects(imageBytes);

    setState(() {
      _result = response.body;
    });
  }

  Future<void> _handleAuthorizationResponse(Uri uri) async {
    if (uri.queryParameters.containsKey('code')) {
      _authorizationCode = uri.queryParameters['code']!;
    } else {
      throw 'Authorization code not found in redirect URI';
    }

  }

  /*Future<String?> getAccessToken() async {
    final authorizationEndpoint =Uri.parse('https://accounts.google.com/o/oauth2/auth');
    final tokenEndpoint = Uri.parse('https://oauth2.googleapis.com/token');
    const identifier = '965832673404-u0jttrd1apu91llhbktsum4u56vsdmq0.apps.googleusercontent.com';
    const secret = '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';
    final redirectUrl = Uri.parse('https://fyprealtimeobjectrecognition.firebaseapp.com/__/auth/handler');
    final credentialsFile = File('assets/client_secret_965832673404-u0jttrd1apu91llhbktsum4u56vsdmq0.apps.googleusercontent.com.json');
    //var credentials = oauth2.Credentials.fromJson(await credentialsFile.readAsString());
    final grant = oauth2.AuthorizationCodeGrant(identifier, authorizationEndpoint, tokenEndpoint, secret: secret);
    final scopes = ['https://www.googleapis.com/auth/cloud-platform'];
    final authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
    await launchUrl(authorizationUrl);
    final link = await linkStream.first;
    final authorizationCode = Uri.parse(link!).queryParameters['code'];
    final client = await oauth2.AuthorizationCodeGrant(identifier, authorizationEndpoint, tokenEndpoint, secret: secret, basicAuth: false).handleAuthorizationResponse({'code': authorizationCode!});   
    accessToken = client.credentials.accessToken;
    return accessToken;
  }*/ 

  /*Future<String?> getAccessToken() async {
    final jsonString = await rootBundle.loadString('assets/fyprealtimeobjectrecognition-9ea4f3b9c8c8.json');
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
    final credentials = ServiceAccountCredentials.fromJson(json.decode(jsonString));
    final scopes = ['https://www.googleapis.com/auth/cloud-platform'];
    final client = await GoogleSignIn().signIn();
    //final googleSignInAccount = await googleSignIn.signIn();
    //final headers = await client!.authHeaders;
    
  }*/

  Future<String?> getAccessToken() async {
    final jsonString = await rootBundle.loadString('assets/fyprealtimeobjectrecognition-9ea4f3b9c8c8.json');
    final auth.ServiceAccountCredentials credentials = auth.ServiceAccountCredentials.fromJson(json.decode(jsonString));
    final List<String> scopes = ['https://www.googleapis.com/auth/cloud-platform'];
    final client = await auth.clientViaServiceAccount(credentials, scopes);
    final token = client.credentials.accessToken.data ;
    return token;
  }

  Future<http.Response> detectObjects(List<int> imageBytes) async {
    final uri = Uri.parse('https://asia-southeast1-aiplatform.googleapis.com/v1/projects/$PROJECT_ID/locations/asia-southeast1/endpoints/$ENDPOINT_ID:predict');
    final token = await getAccessToken();
    
    final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json'
    };
    
    final body = json.encode({
      "instances": [
          {
              "images_bytes": "$imageBytes", 
          },
      ],
    });
    return http.post(uri, headers: headers, body: body);
  }
   
  
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageFile != null)
              Image.file(_imageFile!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: getImage,
              icon: const Icon(Icons.image),
              label: const Text('Select Image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _detectObjects,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Detect Objects'),
            ),
            const SizedBox(height: 16),
            if (_result.isNotEmpty)
              Text( 
                'Result: $_result',
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}