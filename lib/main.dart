import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 

import 'app_themes.dart';
import './pages/homepage.dart';

import 'package:flutter/rendering.dart';
//https://api.flutter.dev/flutter/services/

void main() {
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,      
      home: MyHomePage(),
    );
  }
}

