import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';


void main() 
{
    group('SessionFileNameOnDesktopPlatforms Tests: \n', 
    () 
    {      
        // 'The elevated button, for the file picker, is available to the user.'
        testWidgets('The elevated button, for the file picker, is available to the user.', 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
              // Setting a value. 
              // getApplicationFolderPath() is called in initState.
              // Otherwise a "pumpAndSettle timed out" is thrown
              'applicationFolderPath': ""
          });

          // Loading the widget
          await tester.pumpWidget
          (
            MaterialApp(
              home: Scaffold(
                body: CAProcess
                (
                  caPageCallbackFunctionToRefreshThePage: (){},
                  parentCallbackFunctionToSetFocusabilityOfBottomBarItems: (_){},              
                )
              ),
            )
          );
          await tester.pumpAndSettle();

          if (testingDebug) pu.printd("Testing Debug: Platform: ${Platform.operatingSystem}");

          // Verifying the button text present
          expect(find.textContaining('Click to save your data'), findsOneWidget);         
        }
        );
    });
}