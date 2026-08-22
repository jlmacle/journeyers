// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/2_group_problem_solving_group_moods.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";

import "../../../integration_test/externalized_code/externalized_testing_code.dart";

void main() 
{
  Future<void> pumpIdentifierWidget(WidgetTester tester) async
    {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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


  group("GPSGroupMoods Tests: \n", 
  () 
  {
    group("IdentifierWidget \n", 
      () 
      { 
        group("IdentifierWidget: structure \n", 
        () 
        {  
          testWidgets("The edit emoji is present", 
          (WidgetTester tester) async 
          {
            // Pumping the widget
            await pumpIdentifierWidget(tester);

            // Searching the emoji 
            var emojiFinder = find.textContaining(editEmoji);

            expect(emojiFinder, findsOne);
          });    
        
        });


        group("IdentifierWidget: default aspect: \n", 
      () 
      { 
        testWidgets("The default circle color is green", 
        (WidgetTester tester) async 
        {
          // Pumping the widget
          await pumpIdentifierWidget(tester);

          // Verifying the color 
          await gpsTestIdentifierColor(tester, green);
        });          
      
        testWidgets("The delete icon is absent at addition of the identifier", 
        (WidgetTester tester) async 
        {
          // Pumping the widget
          await pumpIdentifierWidget(tester);

          // Searching the delete icon 
          var deleteIconFinder = find.byType(Icon);

          expect(deleteIconFinder, findsNothing);
        });   

      });
      });
    });

}