import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'dart:io';

File? localModelPath;
FirebaseModelDownloadConditions conditions = FirebaseModelDownloadConditions(androidWifiRequired: true);
FirebaseModelDownloader modelDownloader = FirebaseModelDownloader.instance;

Future<void> getModelFromFirebase() async{
  await modelDownloader.getModel("mobilenet_v1", FirebaseModelDownloadType.latestModel)
  .then((_cusModel) async{
    localModelPath!.copy(_cusModel.file.toString());
  });
} 