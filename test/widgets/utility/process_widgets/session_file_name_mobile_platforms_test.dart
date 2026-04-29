import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';

void main() 
{
    // 'SessionFileNameMobilePlatforms Tests'
    group('SessionFileNameMobilePlatforms Tests: \n', 
    () 
    {      
        // "The folder picker is available to the user, when the user didn't select the folder for its files yet"
        testWidgets("The folder picker is available to the user, when the user didn't select of folder for its files yet", 
        (WidgetTester tester) async 
        {

            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
                // Setting to true to avoid having the first-run modal
                'wasFirstRunModalAcknowledged': true, 
                // Setting to false to have the process page
                'wasSessionDataSaved': false,
                // Setting to false to have the folder picker
                'applicationFolderPath': ""
            });

            // Loading the widget
            await tester.pumpWidget
            (
                const MaterialApp(
                home: Scaffold(
                body: CAProcess(),
                ),
            )
            );
            await tester.pumpAndSettle();

            // Verifying the text field absent
            expect(find.textContaining('Please add the file name'), findsNothing);
            
            // Verifying the elevated button present
            expect(find.byType(ElevatedButton), findsOneWidget);            
        }
        );
    });
}