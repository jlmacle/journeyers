// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3_context_analysis_form.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3a_context_analysis_custom_checkbox_with_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3b_context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3c_context_analysis_custom_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_questions_fields.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/custom/text/custom_heading.dart";

import "../../../integration_test/externalized_code/externalized_testing_code.dart";

void main() 
{
  // Labels of the level 2 and 3 titles
  final q = CAQuestionsFields();

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
    await tester.pumpWidget(
        MaterialApp
        (
          home: Scaffold
          (
            body: CAProcess
            (
              caPageCallbackFunctionToRefreshThePage: (){},
              caPageCallbackFunctionToSetFocusabilityOfBottomBarItems: (_){},              
            )
          ),
        )
    );

    // Waiting to pass the circular indicator
    await tester.pump(const Duration(seconds: 2));

    return;
  }
  
  // Method used to find the Text widgets within the expansion tiles
  Finder getFinderForTextsWithinTheExpansionTiles()
  {
    return  
    find.descendant
    (
      of: find.byType(ExpansionTile), 
      matching: find.byType(Text)
    );
  }
  
  // ─── TESTS ───────────────────────────────────────

  group("CAForm Tests: \n", 
  () 
  {  
    group
    (
      "Form: Structure: Root structure: \n",
      ()
      {
        // "Two perspective expansion tiles are present"
        testWidgets
        (
          "Two perspective expansion tiles are present",
          (tester) async
          {
            // Pumping the CAForm widget
            await pumpCAForm(tester);

            // One tile for the individual perspective, one for the group/team perspective
            expect(find.byType(ExpansionTile), findsNWidgets(2));
          },
        );

        // "Individual and group tiles carry the correct heading text"
        testWidgets
        (
          "Individual and group tiles carry the correct heading text",
          (tester) async
          {
            // Pumping the CAForm widget
            await pumpCAForm(tester);

            // Verifying that the first expansion tile title is correct
            var firstExpansionTileTextFinder = getFinderForTextsWithinTheExpansionTiles().first;
            Text firstExpansionTileTextWidget = tester.widget<Text>(firstExpansionTileTextFinder);        
            expect( firstExpansionTileTextWidget.data, q.level2TitleIndividual);

            // Verifying that the second expansion tile title is correct
            var secondExpansionTileTextFinder = getFinderForTextsWithinTheExpansionTiles().last;
            Text secondExpansionTileTextWidget = tester.widget<Text>(secondExpansionTileTextFinder);        
            expect(secondExpansionTileTextWidget.data, q.level2TitleGroup);
          },
        ); 

      });

    // ─── INDIVIDUAL PERSPECTIVE ───────────────────────────────────────
    // "Form: Structure: Individual perspective: \n"
    group
    (
      "Form: Structure: Individual perspective: \n",
      ()
      {
        // "Expanding the tile with the individual perspective reveals all four level-3 section questions"
        testWidgets
        (
          "Expanding the tile with the individual perspective reveals all four level-3 section questions",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
  
            // Opening the individual perspective expansion tile
            await caOpenIndividualExpansionTile(tester);           

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
              if (testingDebug) pu.printd("Testing Debug: Custom heading text: ${textWidget.data}");
            }

            // Verifying the level 3 titles present
            expect(tester.widget<Text>(customHeadingTextFinders.at(1)).data, q.level3TitleBalanceIssue);
            expect(tester.widget<Text>(customHeadingTextFinders.at(2)).data, q.level3TitleWorkplaceIssue);
            expect(tester.widget<Text>(customHeadingTextFinders.at(3)).data, q.level3TitleLegacyIssue);
            expect(tester.widget<Text>(customHeadingTextFinders.at(4)).data, q.level3TitleAnotherIssue);
          },
        );      
      
        // "Expanding the tile with the individual perspective reveals the correct total number of checkbox items: \n"
        // "4 balance + 2 workplace + 1 legacy = 7"
        testWidgets
        (
          "Expanding the tile with the individual perspective reveals the correct total number of checkbox items: \n"
          "4 balance + 2 workplace + 1 legacy = 7",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
            await caOpenIndividualExpansionTile(tester);

            // Getting the first expansion tile
            var individualExpansionTileFinder =  find.byType(ExpansionTile).first;

            // Searching 7 custom checkbox widgets
            expect
            (
              find.descendant(of: individualExpansionTileFinder, matching: find.byType(CACheckboxWithSanitizedAndPaddedTextField)), 
              findsNWidgets(7)
            );
          },
        );
      
        // "Expanding the tile with the individual perspective reveals the correct total number of text field only items: \n"
        // "1 issue of another type = 1"
        testWidgets
        (
          "Expanding the tile with the individual perspective reveals the correct total number of text field only items: \n"
          "1 issue of another type = 1",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
            await caOpenIndividualExpansionTile(tester);

            // Getting the first expansion tile
            var individualExpansionTileFinder =  find.byType(ExpansionTile).first;

            // Searching 1 custom text field widget
            expect
            (
              find.descendant(of: individualExpansionTileFinder, matching: find.byType(CATextFieldSanitizedAndPadded)), 
              findsNWidgets(1)
            );
          },
        );
      
        // ─── INDIVIDUAL PERSPECTIVE: BALANCE SECTION ───────────────────────────────────────
        // "Balance issue: all four item labels are correct after expansion",
        testWidgets
        (          
          "Balance issue: all four item labels are correct after expansion",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
            await caOpenIndividualExpansionTile(tester);

            // Searching the Text widgets for the first expansion tile
            var textFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Text)
            );

            // Debug data
            for (var textElement in textFinders.evaluate())
            {
              Text textWidget = textElement.widget as Text;
              if (testingDebug) pu.printd("Testing Debug: Text: ${textWidget.data}");
            }

            // Verifying the level 3 titles present
            expect(tester.widget<Text>(textFinders.at(2)).data, q.level3TitleBalanceIssueItem1);
            expect(tester.widget<Text>(textFinders.at(3)).data, q.level3TitleBalanceIssueItem2);
            expect(tester.widget<Text>(textFinders.at(4)).data, q.level3TitleBalanceIssueItem3);
            expect(tester.widget<Text>(textFinders.at(5)).data, q.level3TitleBalanceIssueItem4);
          },
        );
      
        // ─── INDIVIDUAL PERSPECTIVE: WORKPLACE SECTION ───────────────────────────────────────
        // "Workplace issue: both item labels are correct after expansion",
        testWidgets
        (
          
          "Workplace issue: both item labels are correct after expansion",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
            await caOpenIndividualExpansionTile(tester);

            // Searching the Text widgets for the first expansion tile
            var textFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Text)
            );

            // Debug data
            for (var textElement in textFinders.evaluate())
            {
              Text textWidget = textElement.widget as Text;
              if (testingDebug) pu.printd("Testing Debug: Text: ${textWidget.data}");
            }

            // Verifying the level 3 titles present
            expect(tester.widget<Text>(textFinders.at(7)).data, q.level3TitleWorkplaceIssueItem1);
            expect(tester.widget<Text>(textFinders.at(8)).data, q.level3TitleWorkplaceIssueItem2);
          },
        );

        // ─── INDIVIDUAL PERSPECTIVE: LEGACY SECTION ───────────────────────────────────────
        // "Legacy issue: the item label is present after expansion",
        testWidgets
        (
          
          "Legacy issue: the item label is present after expansion",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
            await caOpenIndividualExpansionTile(tester);

            // Searching the Text widgets for the first expansion tile
            var textFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Text)
            );

            // Debug data
            for (var textElement in textFinders.evaluate())
            {
              Text textWidget = textElement.widget as Text;
              if (testingDebug) pu.printd("Testing Debug: Text: ${textWidget.data}");
            }

            // Verifying the level 3 title present
            expect(tester.widget<Text>(textFinders.at(10)).data, q.level3TitleLegacyIssueItem1);
          },
        );
      
        // ─── INDIVIDUAL PERSPECTIVE: ANOTHER ISSUE SECTION ───────────────────────────────────────
        // "Another issue: the hint text is present after expansion",
        testWidgets
        (
          
          "Another issue: the hint text is present after expansion",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
            await caOpenIndividualExpansionTile(tester);

            // Searching the Text widgets for the first expansion tile
            var textFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Text)
            );

            // Debug data
            for (var textElement in textFinders.evaluate())
            {
              Text textWidget = textElement.widget as Text;
              if (testingDebug) pu.printd("Testing Debug: Text: ${textWidget.data}");
            }

            // Verifying the level 3 title present
            expect(tester.widget<Text>(textFinders.at(12)).data, pleaseDevelopHint);
          },
        );
      
      }
    );    

    // ─── GROUP/TEAMS PERSPECTIVE ───────────────────────────────────────
    // "Form: Structure: Group/Teams perspective: \n"
    group
    (
      "Form: Structure: Group/Teams perspective: \n",
      ()
      {
        // "Expanding the tile with the group/teams perspective reveals all five level-3 questions",
        testWidgets
        (
          "Expanding the tile with the group/teams perspective reveals all five level-3 questions",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);            

            // Opening the group/team perspective expansion tile
            await caOpenGroupExpansionTile(tester);

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
              if (testingDebug) pu.printd("Testing Debug: Custom heading text: ${textWidget.data}");
            }

            // Verifying the level 3 titles present
            expect(tester.widget<Text>(customHeadingTextFinders.at(1)).data, q.level3TitleGroupsProblematics);
            expect(tester.widget<Text>(customHeadingTextFinders.at(2)).data, q.level3TitleSameProblem);
            expect(tester.widget<Text>(customHeadingTextFinders.at(3)).data, q.level3TitleHarmonyAtHome);
            expect(tester.widget<Text>(customHeadingTextFinders.at(4)).data, q.level3TitleAppreciabilityAtWork);
            expect(tester.widget<Text>(customHeadingTextFinders.at(5)).data, q.level3TitleIncomeEarningAbility);
          },
        );
      
        // "Expanding the tile with the group/teams perspective reveals the correct total number of text field only items: \n"
        // "1 problems the groups/teams are trying to solve = 1"
        testWidgets
        (
          "Expanding the tile with the group/teams perspective reveals the correct total number of text field only items: \n"
          "1 problems the groups/teams are trying to solve = 1",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the group/team perspective expansion tile
            await caOpenGroupExpansionTile(tester);

            // Getting the second expansion tile
            var groupExpansionTileFinder =  find.byType(ExpansionTile).last;

            // Searching 1 custom text field widget
            expect
            (
              find.descendant(of: groupExpansionTileFinder, matching: find.byType(CATextFieldSanitizedAndPadded)), 
              findsNWidgets(1)
            );
          },
        );
      
        // "Expanding the tile with the group/teams perspective reveals the correct total number of segmented button items: \n"
        // "4"
        testWidgets
        (
          "Expanding the tile with the group/teams perspective reveals the correct total number of segmented button items: \n"
          "4",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the group/team perspective expansion tile
            await caOpenGroupExpansionTile(tester);

            // Getting the second expansion tile
            var groupExpansionTileFinder =  find.byType(ExpansionTile).last;

            // Searching 4 custom segmented button widgets
            expect
            (
              find.descendant(of: groupExpansionTileFinder, matching: find.byType(CASegmentedButtonWithSanitizedAndPaddedTextField)), 
              findsNWidgets(4)
            );
          },
        );
      
      }
    ); 

    group("Form: Start values: \n", 
    () 
    { 
        // "At start, when the tile with the individual perspective is unfolded, all checkboxes are unchecked"
        testWidgets("At start, when the tile with the individual perspective is unfolded, all checkboxes are unchecked", 
        (WidgetTester tester) async {

          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the individual perspective expansion tile
          await caOpenIndividualExpansionTile(tester);   

          // Searching the checkboxes present in the sub-tree
          var checkboxFinder = find.descendant
          (
            of: find.byType(ExpansionTile)
                .first, 
            matching: find.byType(Checkbox)                            
          );

          // Verifying all checkboxes unchecked
          for(var checkboxElement in checkboxFinder.evaluate())
          {
            Checkbox checkboxWidget = checkboxElement.widget as Checkbox;
            expect(checkboxWidget.value, false);
          }
            
        }
        );
    
        // "At start, when the tile with the group/teams perspective is unfolded, no selection is present in the segmented buttons"
        testWidgets("At start, when the tile with the group/teams perspective is unfolded, no selection is present in the segmented buttons", 
        (WidgetTester tester) async {

          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the group/teams perspective expansion tile
          await caOpenGroupExpansionTile(tester);   

          // Searching the segmented buttons present in the sub-tree
          var segButtonFinder = find.descendant
          (
            of: find.byType(ExpansionTile)
                .last, 
            matching: find.byType(SegmentedButton)                            
          );

          // Verifying all segmented buttons without selection
          for(var segButtonElement in segButtonFinder.evaluate())
          {
            SegmentedButton segButtonWidget = segButtonElement.widget as SegmentedButton;
            expect(segButtonWidget.selected, {});
          }     
        }
        );
 
    });      
  });

     
}