// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/1_group_problem_solving_problem_to_solve_declaration.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";

void main() 
{
    Future<void> pumpGPSProblemToSolveDeclaration(WidgetTester tester) async
    {
      var tfec = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GPSProblemToSolveDeclaration
            (
              sessionTitleTec: tfec,
              previousSessions: const [],
              onSessionSelected: (_){},
            ),
          ),
        ),
      );
    }

    group("GPSProblemToSolveDeclaration Tests: \n", 
    () 
    {  
      group("Click to Text Field: \n", 
      () 
      { 
          // "Clicking on the title reveals a text field"
          testWidgets("Clicking on the title reveals a text field", 
          (WidgetTester tester) async 
          {
            // Pumping the widget
            await pumpGPSProblemToSolveDeclaration(tester);

            // Verifying the text field absent
            expect(find.byType(TextField), findsNothing);

            // Getting the default title
            var titleFinder = find.text(gpsProcessTitlePlaceholder);

            // Clicking on the default title
            await tester.tap(titleFinder);
            await tester.pumpAndSettle();

            // Verifying the text field present
            expect(find.byType(TextField), findsOne);
          }
          );
      
          // "Clicking on the edit emoji reveals a text field"
          testWidgets("Clicking on the edit emoji reveals a text field", 
          (WidgetTester tester) async 
          {
            // Pumping the widget
            await pumpGPSProblemToSolveDeclaration(tester);

            // Verifying the text field absent
            expect(find.byType(TextField), findsNothing);

            // Getting the edit emoji
            var emojiFinder = find.text(editEmoji);

            // Clicking on the emoji
            await tester.tap(emojiFinder);
            await tester.pumpAndSettle();

            // Verifying the text field present
            expect(find.byType(TextField), findsOne);
          }
          );      
      });

    });
}