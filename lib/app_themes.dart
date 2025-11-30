import 'package:flutter/material.dart';

final Color navyBlue = Color(0xFF0a2e50);
final Color paleCyan = Color(0xFFE9FAFC);


final ThemeData appTheme = ThemeData
(
    scaffoldBackgroundColor: Colors.white,  // left appbar, text field, checkboxes not in white        
    
    colorScheme: ColorScheme.light
    (
      surface: Colors.white, // succeeded for text field, checkboxes       
    ),
    
    appBarTheme: AppBarTheme
    (
      backgroundColor: navyBlue,   
      // backgroundColor: Colors.white, // for constrast testing
      elevation: 0,
      
            
      titleTextStyle: TextStyle
      (
        color: Color(0xFFf6f1e9),           
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    // https://api.flutter.dev/flutter/material/TextTheme-class.html
    textTheme: const TextTheme
    ( // doesn't apply to the appbar
      // https://api.flutter.dev/flutter/material/TextTheme/displayLarge.html
      displayLarge: TextStyle(color: Colors.black),
      // https://api.flutter.dev/flutter/material/TextTheme/displayMedium.html
      displayMedium: TextStyle(color: Colors.black),
      // https://api.flutter.dev/flutter/material/TextTheme/displaySmall.html
      displaySmall: TextStyle(color: Colors.black),
      // https://api.flutter.dev/flutter/material/TextTheme/headlineLarge.html
      headlineLarge: TextStyle(color: Colors.black, fontSize: 32),
      // https://api.flutter.dev/flutter/material/TextTheme/headlineMedium.html
      headlineMedium: TextStyle(color: Colors.black, fontSize: 28),
      // https://api.flutter.dev/flutter/material/TextTheme/headlineSmall.html
      headlineSmall: TextStyle(color: Colors.black, fontSize: 24),
      // https://api.flutter.dev/flutter/material/TextTheme/titleLarge.html
      titleLarge: TextStyle(color: Colors.black, fontSize: 22),
      // https://api.flutter.dev/flutter/material/TextTheme/titleMedium.html
      titleMedium: TextStyle(color: Colors.black, fontSize: 16),
      // https://api.flutter.dev/flutter/material/TextTheme/titleSmall.html
      titleSmall: TextStyle(color: Colors.black, fontSize: 14),
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black),
      labelLarge: TextStyle(color: Colors.black),
      labelMedium: TextStyle(color: Colors.black, fontSize: 12),
      labelSmall: TextStyle(color: Colors.black),
    ),
    
    inputDecorationTheme: InputDecorationTheme
    (
      border: OutlineInputBorder
      (
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),          
      filled: true,          
      fillColor:paleCyan,
      
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData
    (
      style:  ButtonStyle
      (
        foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
      )
    ),
    segmentedButtonTheme: SegmentedButtonThemeData
    (         
      style: ButtonStyle
      (            
        backgroundColor: WidgetStateProperty.resolveWith<Color>
        (
          (Set<WidgetState> states) 
          {
            if (states.contains(WidgetState.selected)) 
            {
              return paleCyan;
            }
            return Colors.transparent;                
          },
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData
    (
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) 
        {
          if (states.contains(WidgetState.selected)) 
          {
            return navyBlue;
          }
          return Colors.transparent;   
        }         
      )  
    ),
    bannerTheme: MaterialBannerThemeData
    (
      backgroundColor: const Color.fromARGB(255, 13, 13, 49),
    ),
    
    useMaterial3: true,
  );