import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:shared_preferences/shared_preferences.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

void main() 
{
  const textFieldHintPart = "Please add the";

    group("SessionFileNameOnMobilePlatforms Tests: \n", 
    () 
    {      
        // "On mobile: The folder picker is available to the user, when the user didn't select the folder for its files yet"
        // Important: As a widget test, runs on Windows, even if Android is selected as a device.
        testWidgets("On mobile: The folder picker is available to the user, when the user didn't select of folder for its files yet.", 
        (WidgetTester tester) async 
        {

            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
                // Setting to "" to have the folder picker
                "applicationFolderPath": ""
            });

            // Loading the widget
            await tester.pumpWidget
            (
              MaterialApp(
                home: Scaffold(
                  body: CAProcess
                  (
                    caPageCallbackFunctionToRefreshThePage: (){},
                    caPageCallbackFunctionToSetFocusabilityOfBottomBarItems: (_){},              
                  )
                ),
              )
            );
            await tester.pumpAndSettle();

            if (testingDebug) pu.printd("Testing Debug: Platform: ${Platform.operatingSystem}");
            if (Platform.isAndroid || Platform.isIOS)
            {
              // Verifying the text field absent
              expect(find.textContaining(textFieldHintPart), findsNothing);
              
              // Verifying the elevated button present
              expect(find.byType(ElevatedButton), findsOneWidget);  
            }
                      
        }
        );

        // "On mobile: The text field is available for the user to enter the file name, when the user did select a folder for its files"
        // Important: As a widget test, runs on Windows, even if Android is selected as a device.
        testWidgets("On mobile: The text field is available for the user to enter the file name, when the user did select a folder for its files.", 
        (WidgetTester tester) async 
        {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
                // Setting to "a/path" to not have the folder picker
                "applicationFolderPath": "a/path"
            });

            // Loading the widget
            await tester.pumpWidget
            (
                MaterialApp(
                home: Scaffold(
                body: CAProcess
                (
                  caPageCallbackFunctionToRefreshThePage: (){},
                  caPageCallbackFunctionToSetFocusabilityOfBottomBarItems: (_){},              
                )
                ),
            )
            );
            await tester.pumpAndSettle();

            if (testingDebug) pu.printd("Testing Debug: Platform: ${Platform.operatingSystem}");

            if (Platform.isAndroid || Platform.isIOS)
            {
              // Verifying the elevated button absent
              expect(find.byType(ElevatedButton), findsNothing);   

              // Verifying the text field present
              expect(find.textContaining(textFieldHintPart), findsOneWidget);   
            }                  
        }
        );

    });
}