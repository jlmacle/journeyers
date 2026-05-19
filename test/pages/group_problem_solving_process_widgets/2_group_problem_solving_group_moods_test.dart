// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/2_group_problem_solving_group_moods.dart';

void main() 
{
  Future<void> pumpIdentifierWidget(WidgetTester tester) async
    {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdentifierWidget
            (
                value: "Name", 
                isEditMode: false, 
                isDeleteMode: false,
                editionHappened: false,
                onDelete:() {}, 
                onEdit:() {}, 
                onSwipe:(_) {}, 
                onClick:(_) {}, 
            ),
          ),
        ),
      );
    }

    // 'GPSGroupMoods Tests: \n'
    group('GPSGroupMoods Tests: \n', 
    () 
    {  
      // "Stakeholder identifiers' colors: \n"
      group("Stakeholder identifiers' colors: \n", 
      () 
      { 
        // 'The default circle color is green'
        testWidgets('The default circle color is green', 
        (WidgetTester tester) async 
        {
          // Pumping the widget
          await pumpIdentifierWidget(tester);

          // Verifying the default circle color is green
          var containerFinder = find.byType(Container);

          Container container = tester.widget<Container>(containerFinder);
          var boxDecoration = container.decoration as BoxDecoration;
          var border = boxDecoration.border as Border;

          expect(
            border.top.color,
            green,
          );

          expect(
            border.bottom.color,
            green,
          );

          expect(
            border.right.color,
            green,
          );

          expect(
            border.left.color,
            green,
          );
        });          
      });

    });
}