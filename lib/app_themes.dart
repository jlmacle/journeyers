import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
        scaffoldBackgroundColor: Colors.white,  // left appbar, text field, checkboxes not in white        
        
        colorScheme: ColorScheme.light(
          surface: Colors.white, // succeeded for text field, checkboxes 
          
        ),
        
        appBarTheme: const AppBarTheme(
          // backgroundColor: Color(0xFF1ecbe1),
          backgroundColor: Color(0xFF0a2e50),   
          // backgroundColor: Colors.white, // for constrast testing
          
          // backgroundColor: Color.fromARGB(255, 77, 4, 52),  
          elevation: 0,
                
          titleTextStyle: TextStyle(
            color: Color(0xFFf6f1e9),           
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        textTheme: const TextTheme( // doesn't apply to the appbar
          displayLarge: TextStyle(color: Colors.black),
          displayMedium: TextStyle(color: Colors.black),
          displaySmall: TextStyle(color: Colors.black),
          headlineLarge: TextStyle(color: Colors.black),
          headlineMedium: TextStyle(color: Colors.black),
          headlineSmall: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
          titleSmall: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
          labelLarge: TextStyle(color: Colors.black),
          labelMedium: TextStyle(color: Colors.black),
          labelSmall: TextStyle(color: Colors.black),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),          
          filled: true,          
          fillColor:Color(0xFFE9FAFC),
          
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData
        (
          // The 'style' property takes a ButtonStyle
          style: ButtonStyle
          (
            // Use MaterialStateProperty.resolveWith to check the state
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color(0xFFE9FAFC); // Example: Set selected color to green
                }
                return Colors.transparent;
                
              },
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) 
            {
              if (states.contains(WidgetState.selected)) {
                return Color(0xFF0a2e50);  // Same navy blue
              }
              return Colors.transparent;   
            }         
          )  
        ),
        // buttonTheme: ButtonThemeData(
        //   focusColor: Color(0xFFB9EFF6),

        // ),
        
        useMaterial3: true,
      );