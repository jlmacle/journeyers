// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/1_group_problem_solving_problem_to_solve_declaration.dart';

void main() 
{
    Future<void> pumpGPSProblemToSolveDeclaration(WidgetTester tester) async
    {
      var tec = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GPSProblemToSolveDeclaration
            (
              problemTitleController: tec,
              previousSessions: const [],
              onSessionSelected: (_){},
            ),
          ),
        ),
      );
    }

    // 'GPSProblemToSolveDeclaration Tests: \n'
    group('GPSProblemToSolveDeclaration Tests: \n', 
    () 
    {  
      // 'Click to Text Field: \n'
      group('Click to Text Field: \n', 
      () 
      { 
          // 'Clicking on the title reveals a text field'
          testWidgets('Clicking on the title reveals a text field', 
          (WidgetTester tester) async 
          {
            // Pumping the widget
            await pumpGPSProblemToSolveDeclaration(tester);

            // Verifying the text field absent
            expect(find.byType(TextField), findsNothing);

            // Getting the default title
            var titleFinder = find.text("Problem To Solve");

            // Clicking on the default title
            await tester.tap(titleFinder);
            await tester.pumpAndSettle();

            // Verifying the text field present
            expect(find.byType(TextField), findsOne);
          }
          );
      
          // 'Clicking on the edit emoji reveals a text field'
          testWidgets('Clicking on the edit emoji reveals a text field', 
          (WidgetTester tester) async 
          {
            // Pumping the widget
            await pumpGPSProblemToSolveDeclaration(tester);

            // Verifying the text field absent
            expect(find.byType(TextField), findsNothing);

            // Getting the edit emoji
            var emojiFinder = find.text("✏️");

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