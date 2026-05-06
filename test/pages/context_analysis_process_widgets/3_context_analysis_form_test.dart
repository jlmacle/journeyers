// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3_context_analysis_form.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_questions_fields.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';

void main() 
{
  // ─── HELPER FUNCTIONS ───────────────────────────────────────

  // Method used to pump the CAForm widget
  Future<void> pumpCAForm(WidgetTester tester) async
  {
    return await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body:  CAForm.fromDTO
            (
              dtoCAForm: DTOCAForm(),
              parentCallbackFunctionToRefreshTheCAPage: () {},
              parentCallbackFunctionToSetFocusabilityOfBottomBarItems: (_) {},
            )
          )
        )
    );
  }

  // Method used to pump the CAProcess widget
  Future<void> pumpCAProcess(WidgetTester tester) async
  {
    return await tester.pumpWidget(
        const MaterialApp
        (
          home: Scaffold
          (
            body: CAProcess()
          ),
        )
    );
  }


  // Method used to find the expansion tiles
  Finder getTheExpansionTilesFinder()
  {
    return  
    find.descendant
    (
      of: find.byType(ExpansionTile), 
      matching: find.byType(Text)
    );
  }
  
  // ─── TESTS ───────────────────────────────────────

  // 'CAForm Tests: \n'
  group('CAForm Tests: \n', 
  () 
  {  
    // 'Form: Structure: \n'
    group
    (
      'Form: Structure: Root structure: \n',
      ()
      {
        // 'Two perspective expansion tiles are present'
        testWidgets
        (
          'Two perspective expansion tiles are present',
          (tester) async
          {
            await pumpCAForm(tester);

            // One tile for the individual perspective, one for the group/team perspective
            expect(find.byType(ExpansionTile), findsNWidgets(2));
          },
        );

        // 'Individual and group tiles carry the correct heading text'
        testWidgets
        (
          'Individual and group tiles carry the correct heading text',
          (tester) async
          {
            final q = CAQuestionsFields();
            await pumpCAForm(tester);

            // Verifying that the first expansion tile text is correct
            var firstExpansionTileTextFinder = getTheExpansionTilesFinder().first;
            Text firstExpansionTileTextWidget = tester.widget<Text>(firstExpansionTileTextFinder);        
            expect( firstExpansionTileTextWidget.data, q.level2TitleIndividual);

            // Verifying that the second expansion tile text is correct
            var secondExpansionTileTextFinder = getTheExpansionTilesFinder().last;
            Text secondExpansionTileTextWidget = tester.widget<Text>(secondExpansionTileTextFinder);        
            expect(secondExpansionTileTextWidget.data, q.level2TitleGroup);
          },
        ); 

      });
    group
    (
      'Form: Structure: Individual perspective: \n',
      ()
      {
        // 'Expanding the tile with the individual perspective reveals all four level-3 section headings'
        testWidgets
        (
          'Expanding the tile with the individual perspective reveals all four level-3 section headings',
          (tester) async
          {
            final q = CAQuestionsFields();
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);

            // Waiting to pass the circular indicator
            await tester.pump(const Duration(seconds: 2));
            
            // Opening the individual perspective expansion tile
            await tester.tap(find.text(q.level2TitleIndividual));

            // Waiting for the expansion tile to be unfolded before searching descendants
            await tester.pump(const Duration(seconds: 2));

            // pumpAndSettle timed out exception if pumpAndSettle is used
            // await tester.pumpAndSettle();

            // Searching the custom headings text for the first expansion tile
            var customHeadingTextFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.descendant
              (
                of: find.byType(CustomHeading),
                matching: find.byType(Text)
              )
            );

            // Debug data
            for (var textElement in customHeadingTextFinders.evaluate())
            {
              Text textWidget = textElement.widget as Text;
              if (testingDebug) pu.printd("Custom heading text: ${textWidget.data}");
            }

            // Verifying the level 3 titles present
            expect(tester.widget<Text>(customHeadingTextFinders.at(1)).data, q.level3TitleBalanceIssue);
            expect(tester.widget<Text>(customHeadingTextFinders.at(2)).data, q.level3TitleWorkplaceIssue);
            expect(tester.widget<Text>(customHeadingTextFinders.at(3)).data, q.level3TitleLegacyIssue);
            expect(tester.widget<Text>(customHeadingTextFinders.at(4)).data, q.level3TitleAnotherIssue);
          },
        );      
      }
    );    
  });

    group
    (
      'Form: Structure: Group/Teams perspective: \n',
      ()
      {
        // 'Expanding the tile with the group/teams perspective reveals all five level-3 section headings',
        testWidgets
        (
          'Expanding the tile with the group/teams perspective reveals all five level-3 section headings',
          (tester) async
          {
            final q = CAQuestionsFields();
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);            

            // Opening the group/team perspective expansion tile
            await tester.tap(find.text(q.level2TitleGroup));

            // Waiting for the expansion tile to be unfolded before searching descendants
            await tester.pump(const Duration(seconds: 2));

            // pumpAndSettle timed out exception if pumpAndSettle is used
            // await tester.pumpAndSettle();

            // Searching the custom headings text for the second expansion tile
            var customHeadingTextFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .last, 
              matching: find.descendant
              (
                of: find.byType(CustomHeading),
                matching: find.byType(Text)
              )
            );

            // Debug data
            for (var textElement in customHeadingTextFinders.evaluate())
            {
              Text textWidget = textElement.widget as Text;
              if (testingDebug) pu.printd("Custom heading text: ${textWidget.data}");
            }

            // Verifying the level 3 titles present
            expect(tester.widget<Text>(customHeadingTextFinders.at(1)).data, q.level3TitleGroupsProblematics);
            expect(tester.widget<Text>(customHeadingTextFinders.at(2)).data, q.level3TitleSameProblem);
            expect(tester.widget<Text>(customHeadingTextFinders.at(3)).data, q.level3TitleHarmonyAtHome);
            expect(tester.widget<Text>(customHeadingTextFinders.at(4)).data, q.level3TitleAppreciabilityAtWork);
            expect(tester.widget<Text>(customHeadingTextFinders.at(5)).data, q.level3TitleIncomeEarningAbility);
          },
        );
      }
    );
}