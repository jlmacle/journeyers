import 'package:flutter/material.dart';

// TODO: to clean at some point. That probably can be simplified.

//*********************  Colors  *********************//
final Color navyBlue = Color(0xFF0a2e50);
final Color paleCyan = Color(0xFFE9FAFC);


//*********************  Gaps  *********************//
// Gaps: gaps for the context analysis form
final double postHeadingLevel2Gap = 20;
final double preAndPostLevel2DividerGap = 20;
final double preAndPostLevel3DividerGap = 15;
final double level3AndSegmentedButtonGap = 15;
final double betweenLevel2DividerThickness = 3;
final double betweenLevel3DividerThickness = 1;


//*********************  Padding  *********************//
// Paddings: elevated buttons padding
final double elevatedButtonPadding = 20;
final double elevatedButtonPaddingTop = 20;
final double elevatedButtonPaddingBottom = 20;


//*********************  Text Styles  *********************//

// Text styles: generic text styles
const TextStyle defaultConstHeadingStyle = TextStyle
(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: Color(0xFF000000)
);

const TextStyle underlinedConstHeadingStyle = TextStyle
(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: Color(0xFF000000),
  decoration: TextDecoration.underline
);

const TextStyle unselectedCheckboxTextStyle = TextStyle
(
  fontSize: 24,
  color: Colors.black,
  decoration: TextDecoration.none
);

const TextStyle selectedCheckboxTextStyle = TextStyle
(
  fontSize: 24,
  color: Colors.black,
  decoration: TextDecoration.underline
);

final TextStyle elevatedButtonTextStyle = TextStyle
(
  fontSize: 20,
  fontWeight: FontWeight.normal,
);

final TextStyle customExpansionTileTextStyle = TextStyle
(
  color: Colors.black,
  fontSize: 20,
  fontWeight: FontWeight.w500,
);

final TextStyle styleExpansionTileTitle = TextStyle
(
  fontSize: 20, fontWeight: FontWeight.w500
);

final TextStyle styleExpandedTitleSubTitle = TextStyle(fontSize: 16);

final TextStyle feedbackMessageStyle = TextStyle
(
  fontSize: 18,
  fontWeight: FontWeight.normal,
);


// Text styles: context analysis page related styles
final TextStyle analysisTitleStyle = TextStyle
(
  fontSize: 20,
  fontWeight: FontWeight.normal,
);

final TextStyle dialogStyle = TextStyle
(
  color: Colors.black,
  fontSize: 20,
  fontWeight: FontWeight.normal,
);

final TextStyle dialogAcknowledgedStyle = TextStyle
(
  color: Colors.purple.shade400,
  fontSize: 20,
);

// Text styles: dashboard page related styles
final TextStyle styleDataAbsent = TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black);


//*********************  Text Field Hints  *********************//
// Text field hints: context analysis page related text field hints
const String pleaseDescribeTextHouseholdHint =
    'Please describe the past outcomes for the household, '
    'if some seem to have been out of their comfort zone for too long, '
    'and the more desirable outcomes for the household.';

const String pleaseDescribeTextWorkplaceHint =
    'Please describe the past outcomes for the workplace, '
    'if some seem to have been out of their comfort zone for too long, '
    'and the more desirable outcomes for the workplace and for the household.';

const String pleaseDevelopOrTakeNotesHint = 'Please develop.';

const String pleaseDescribeTextGroupsHint =
    'Please describe the problem(s) that the groups/teams are trying to solve.';

const String textFieldHint = 'Please enter some text';


//*********************  ThemeData  *********************//
// ThemeData
final ThemeData appTheme = ThemeData
(
  scaffoldBackgroundColor:
      Colors.white, // left appbar, text field, checkboxes not in white


  //*********************  AppBarTheme  *********************//
  appBarTheme: AppBarTheme
  (
    backgroundColor: navyBlue,
    elevation: 0,

    titleTextStyle: TextStyle
    (
      color: Color(0xFFf6f1e9), // appbar white
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),


  //*********************  BannerTheme  *********************//
  bannerTheme: MaterialBannerThemeData
  (
    backgroundColor: const Color.fromARGB(255, 13, 13, 49),
  ),


  //*********************  CheckboxTheme  *********************//
  checkboxTheme: CheckboxThemeData
  (
    fillColor: WidgetStateProperty.resolveWith<Color>
    (
      (Set<WidgetState> states) 
      {
        if (states.contains(WidgetState.selected)) 
        {return navyBlue;}
        return Colors.transparent;
      }
    ),
  ),
 

  //*********************  ChipTheme  *********************//
  // to remove the emerald green color from appearing
  chipTheme: ChipThemeData
  (
    backgroundColor: navyBlue,
    labelStyle: TextStyle
    (
      color: Color(0xFFf6f1e9), // appbar white
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    surfaceTintColor: Colors.transparent, 
    
    selectedColor: navyBlue, 
    selectedShadowColor: navyBlue,
    checkmarkColor: Colors.black,

    // added to stop a green flash
    color: WidgetStateProperty.resolveWith<Color?>((states) {
    if (states.contains(WidgetState.selected)) {
      return navyBlue; 
    }
    return navyBlue; 
  }),
    
    brightness: Brightness.light, 
  ),


  //*********************  ColorScheme  *********************//
  colorScheme: ColorScheme.light
  (
    surface: Colors.white, // succeeded for text field, checkboxes
  ),


  //*********************  ElevatedButtonTheme  *********************//
  elevatedButtonTheme: ElevatedButtonThemeData
  (
    style: ButtonStyle
    (
      foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
      backgroundColor: WidgetStateProperty.all<Color>(paleCyan),
      surfaceTintColor: WidgetStateProperty.resolveWith<Color>
      (
        (Set<WidgetState> states) 
        {
          if (states.contains(WidgetState.hovered)) {return paleCyan;} 
          else if (states.contains(WidgetState.focused)) {return paleCyan;}
          return paleCyan;
        }
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color?>
      (
        (Set<WidgetState> states) 
        {
          if (states.contains(WidgetState.hovered)) {return Colors.transparent;}
          if (states.contains(WidgetState.pressed)) {return Colors.transparent;}
          return null;
        }
      ),
    ),
  ),


  //*********************  InputDecorationTheme  *********************//
  inputDecorationTheme: InputDecorationTheme
  (
    border: OutlineInputBorder
    (
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: paleCyan,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  ),
  

  //*********************  SegmentedButtonTheme  *********************//
  segmentedButtonTheme: SegmentedButtonThemeData
  (
    style: ButtonStyle
    (
      backgroundColor: WidgetStateProperty.resolveWith<Color>
      (
        (Set<WidgetState> states) 
        {
          if (states.contains(WidgetState.selected)) {return paleCyan;}
          return Colors.transparent;
        }
      ),
    ),
  ),

  //*********************  TextButton  *********************//
  textButtonTheme: TextButtonThemeData( // TODO: code to clean
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
      surfaceTintColor: WidgetStateProperty.all<Color>(Colors.white),
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered) || 
              states.contains(WidgetState.pressed)) {
            return Colors.transparent;
          }
          return null;
        },
      ),
    ),
  ),

  //*********************  TextTheme  *********************//
  // https://api.flutter.dev/flutter/material/TextTheme-class.html
  textTheme: const TextTheme
  (
    // doesn't apply to the appbar
    // https://api.flutter.dev/flutter/material/TextTheme/displayLarge.html
    // displayLarge: TextStyle(color: Colors.black),
    // https://api.flutter.dev/flutter/material/TextTheme/displayMedium.html
    // displayMedium: TextStyle(color: Colors.black),
    // https://api.flutter.dev/flutter/material/TextTheme/displaySmall.html
    // displaySmall: TextStyle(color: Colors.black),
    // https://api.flutter.dev/flutter/material/TextTheme/headlineLarge.html
    headlineLarge: TextStyle
    (
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.w900,
    ),
    // https://api.flutter.dev/flutter/material/TextTheme/headlineMedium.html
    headlineMedium: TextStyle
    (
      color: Colors.black,
      fontSize: 23,
      fontWeight: FontWeight.bold,
    ),
    // https://api.flutter.dev/flutter/material/TextTheme/headlineSmall.html
    headlineSmall: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w500),
    // https://api.flutter.dev/flutter/material/TextTheme/titleLarge.html
    titleLarge: TextStyle(color: Colors.black, fontSize: 20),
    // https://api.flutter.dev/flutter/material/TextTheme/titleMedium.html
    titleMedium: TextStyle(color: Colors.black, fontSize: 18),
    // https://api.flutter.dev/flutter/material/TextTheme/titleSmall.html
    titleSmall: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    bodySmall: TextStyle(color: Colors.black),
    labelLarge: TextStyle(color: Colors.black),
    labelMedium: TextStyle(color: Colors.black, fontSize: 12),
    labelSmall: TextStyle(color: Colors.black),
  ),

  useMaterial3: true,
);
