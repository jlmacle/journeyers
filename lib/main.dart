import 'package:flutter/material.dart';
import 'app_themes.dart';
import './pages/homepage.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'; // to temporarily avoid screen rotation
//https://api.flutter.dev/flutter/services/

void main() {
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown, // Optional: if you want upside-down portrait
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,      
      home: const MyHomePage(),
    );
  }
}

