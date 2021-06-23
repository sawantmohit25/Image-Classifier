import 'package:flutter/material.dart';
import 'package:image_classifier_app/image_classifier.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:ThemeData.dark(),
      debugShowCheckedModeBanner:false,
      home: ImageClassifier(),
    );
  }
}

