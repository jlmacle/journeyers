import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/2_context_analysis_keywords_declaration.dart";

void main() 
{
    group("CAKeywordsDeclaration Tests: ", 
    () 
    { 
      testWidgets("A keyword is added to the display, when added from the text field: ", 
      (WidgetTester tester) async 
      {
        const kw = "kw";

        // Building the widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CAKeywordsDeclaration
              (
                keywordsWhenEdition: const {},
                onKeywordsUpdatedProcessCallbackFunction: (_){}
              )
            ),
          ),
        );

        // Adding a keyword with the text field
        await tester.enterText(find.byType(TextField), kw);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Verifying the presence of an InputChip Text
        var inputChipTextFinder = find.descendant(of: find.byType(InputChip), matching: find.byType(Text));
        expect(inputChipTextFinder, findsOneWidget);

        // Verifying the text on the InputChip Text
        var inputChipTextWidget = tester.widget<Text>(inputChipTextFinder);
        expect(inputChipTextWidget.data, kw);
      }
      );

      testWidgets("A keyword added twice, is displayed once: ", 
      (WidgetTester tester) async 
      {
        const kw = "kw";

        // Building the widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CAKeywordsDeclaration
              (
                keywordsWhenEdition: const {},
                onKeywordsUpdatedProcessCallbackFunction: (_){}
              )
            ),
          ),
        );

        // Adding a keyword twice with the text field
        await tester.enterText(find.byType(TextField), kw);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        await tester.enterText(find.byType(TextField), kw);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Verifying the presence of a single InputChip Text
        var inputChipTextFinder = find.descendant(of: find.byType(InputChip), matching: find.byType(Text));
        expect(inputChipTextFinder, findsOneWidget);

        // Verifying the text on the InputChip Text
        var inputChipTextWidget = tester.widget<Text>(inputChipTextFinder);
        expect(inputChipTextWidget.data, kw);
      }
      );
  
      testWidgets("Keywords are added in alphabetical order: ", 
      (WidgetTester tester) async 
      {
        // Building the widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CAKeywordsDeclaration
              (
                keywordsWhenEdition: const {},
                onKeywordsUpdatedProcessCallbackFunction: (_){}
              )
            ),
          ),
        );

        // Adding the keywords with the text fields: B, A, C
        await tester.enterText(find.byType(TextField), "B");
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        await tester.enterText(find.byType(TextField), "A");
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        await tester.enterText(find.byType(TextField), "C");
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();


        // Verifying the presence of 3 InputChip Texts
        var inputChipTextFinder = find.descendant(of: find.byType(InputChip), matching: find.byType(Text));
        expect(inputChipTextFinder, findsNWidgets(3));

        // Verifying their order
        const expectedOrder = ["A", "B", "C"];
        int index = 0;
        for (Element inputChipTextFound in inputChipTextFinder.evaluate())
        {
            // Accessing the widget from the element
            var inputChipTextWidget = inputChipTextFound.widget as Text;
            expect (inputChipTextWidget.data, expectedOrder[index]);
            index++;
        }
      }
      );

      testWidgets("20 keywords can be added to the context analysis, without having an exception: ", 
      (WidgetTester tester) async 
      {
        // Building the widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CAKeywordsDeclaration
              (
                keywordsWhenEdition: const {},
                onKeywordsUpdatedProcessCallbackFunction: (_){}
              )
            ),
          ),
        );

        // Adding 20 keywords
        for (var index=1; index <= 20; index++)
        {
          await tester.enterText(find.byType(TextField), "Household$index");
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
        }        

        // Verifying the presence of 20 InputChip Texts
        var inputChipTextFinder = find.descendant(of: find.byType(InputChip), matching: find.byType(Text));
        expect(inputChipTextFinder, findsNWidgets(20));
      }
      );
  
      testWidgets("No counter is displayed", 
      (WidgetTester tester) async 
      {
        // Building the widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CAKeywordsDeclaration
              (
                keywordsWhenEdition: const {},
                onKeywordsUpdatedProcessCallbackFunction: (_){}
              )
            ),
          ),
        );

        expect(find.textContaining("/"), findsNothing);
      }
      );
  

      group("Colors check", 
        ()
        {
          testWidgets("The input chips are navyBlue", 
          (WidgetTester tester) async 
          {
            // Building the widget
            await tester.pumpWidget(
              MaterialApp(
                theme: appTheme,
                home: Scaffold(
                  body: CAKeywordsDeclaration
                  (
                    keywordsWhenEdition: const {},
                    onKeywordsUpdatedProcessCallbackFunction: (_){}
                  )
                ),
              ),
            );

            // Adding a keyword with the text field
            await tester.enterText(find.byType(TextField), "kw");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pump();

            // Verifying the color
            var inputChipsFinder = find.byType(InputChip);
            final theme = Theme.of(tester.element(inputChipsFinder.first));
            final chipTheme = theme.chipTheme;
            // Unselected state value 
            // resolve({WidgetState.selected}) for a selected state value
            final defaultColor = chipTheme.color?.resolve({});
            expect(defaultColor, navyBlue);
          }
          );
  
        }
      );
  });


}