import 'package:flutter/material.dart';
import 'package:flutter_mediapipe_chat/flutter_mediapipe_chat.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final chatPlugin = FlutterMediapipeChat();

  final modelBytes = await rootBundle.load('assets/models/gemma-2b-it-gpu-int4.bin');
  final tempDir = await getTemporaryDirectory();
  final modelFile = File('${tempDir.path}/gemma-2b-it-gpu-int4.bin');
  await modelFile.writeAsBytes(modelBytes.buffer.asUint8List(modelBytes.offsetInBytes, modelBytes.lengthInBytes));

  final config = ModelConfig(
    path: modelFile.path,
    temperature: 0.7,
    maxTokens: 1024,
    topK: 30,
    randomSeed: 42,
    loraPath: null,
  );

  await chatPlugin.loadModel(config);
  String? response = await chatPlugin.generateResponse("Hello give me 3 Polish cities ");
  if (response != null) {
    print("Model Response: $response");
  } else {
    print("No response from model.");
  }
  runApp(MyApp(response: response ?? "No response from model."));
}

class MyApp extends StatelessWidget {
  final String response;
  const MyApp({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: Center(child: Text(response)));
  }
}
