// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/2_group_problem_solving_group_moods.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';

void main() 
{
  Future<void> pumpGPSProcess(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GPSProcess
          (
            parentCallbackFunctionToRefreshTheGPSPage: () {},
          ),
        ),
      ),
    );
  }

  // 'GPSProcess Tests: \n'
  group('GPSProcess Tests: \n', 
  () 
  {  
    // "Stakeholder identifiers: \n"
    group("Stakeholder identifiers: \n", 
    () 
    {      
      // 'Stakeholder identifiers can be added'
      testWidgets('Stakeholder identifiers can be added', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSProcess(tester);

        // Finding the add emoji    
        var emojiFinder = find.text(addEmoji);

        // Adding identifiers
        for (var i = 1; i <= 3; i++)
        {
          // Tapping to add
          await tester.tap(emojiFinder);
          // pumpAndSettle timed out
          // await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2));
          // Verifying present
          expect(find.byType(IdentifierWidget), findsNWidgets(i));
        }

      });          
    
      // 'Stakeholder identifiers can be edited'
      testWidgets('Stakeholder identifiers can be edited', 
      (WidgetTester tester) async 
      {
        var someText = "someText";

        // Pumping the widget
        await pumpGPSProcess(tester);

        // Finding the add emoji    
        var emojiFinder = find.text(addEmoji);

        // Adding an identifier
        // Tapping to add
        await tester.tap(emojiFinder);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        // Verifying the identifier present
        var identifierWidgetFinder = find.byType(IdentifierWidget);
        expect(identifierWidgetFinder, findsOne);

        // Searching the edit button
        var editButtonFinder = find.descendant
                              (
                                of: find.byType(ElevatedButton),
                                matching: find.text(editEmoji)
                              );
        
        var totalButton = editButtonFinder.evaluate().length;
        if (testingDebug) pu.printd('Testing Debug: totalButton: $totalButton');

        // Tapping the edit button
        await tester.tap(editButtonFinder);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        
        // Tapping the identifier for edition
        await tester.tap(identifierWidgetFinder);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));

        // Searching the text field
        var textFieldFinder = find.descendant
        (
          of: find.byType(AlertDialog), 
          matching: find.byType(TextField)
        );

        var totalTextField = textFieldFinder.evaluate().length;
        if (testingDebug) pu.printd('Testing Debug: totalTextField: $totalTextField');

        //Entering some text
        await tester.enterText(textFieldFinder, someText);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));

        // Verifying the alert dialog absent
        expect(find.byType(AlertDialog), findsNothing);

        // Verifying the text present in the identifier
        expect
        (
          find.descendant
          (
            of: find.byType(IdentifierWidget), 
            matching: find.text(someText)
          ),
          findsOne
        );
      });          
    
    });
  });
}