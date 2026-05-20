// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/2_group_problem_solving_group_moods.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';

void main() 
{
  Future<void> pumpIdentifierWidget(WidgetTester tester) async
    {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdentifierWidget
            (
                isEditMode: false, 
                isDeleteMode: false,
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
      // "Stakeholder identifiers' default aspect: \n"
      group("Stakeholder identifiers' default aspect: \n", 
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

      // 'The delete icon is absent at addition of the identifier'
      testWidgets('The delete icon is absent at addition of the identifier', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpIdentifierWidget(tester);

        // Searching the delete icon 
        var deleteIconFinder = find.byType(Icon);

        expect(deleteIconFinder, findsNothing);
      });      
    
      // 'The edit emoji is present at addition of the identifier'
      testWidgets('The edit emoji is present at addition of the identifier', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpIdentifierWidget(tester);

        // Searching the emoji 
        var emojiFinder = find.textContaining(editEmoji);

        expect(emojiFinder, findsOne);
      });
    
    });
}