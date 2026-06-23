import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/2_context_analysis_keywords_declaration.dart';

void main() 
{
    group('CAKeywordsDeclaration Tests: \n', 
    () 
    { 
      // 'A keyword is added to the display, when added from the text field: \n'
      testWidgets('A keyword is added to the display, when added from the text field: \n', 
      (WidgetTester tester) async 
      {
        const String kw = "kw";

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


      // 'A keyword added twice, is displayed once: \n'
      testWidgets('A keyword added twice, is displayed once: \n', 
      (WidgetTester tester) async 
      {
        const String kw = "kw";

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
  
      // 'Keywords are added in alphabetical order: \n'
      testWidgets('Keywords are added in alphabetical order: \n', 
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
        await tester.enterText(find.byType(TextField), 'B');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        await tester.enterText(find.byType(TextField), 'A');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        await tester.enterText(find.byType(TextField), 'C');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();


        // Verifying the presence of 3 InputChip Texts
        var inputChipTextFinder = find.descendant(of: find.byType(InputChip), matching: find.byType(Text));
        expect(inputChipTextFinder, findsNWidgets(3));

        // Verifying their order
        const expectedOrder = ['A', 'B', 'C'];
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

      // '20 keywords can be added to the context analysis, without having an exception: \n'
      testWidgets('20 keywords can be added to the context analysis, without having an exception: \n', 
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
          await tester.enterText(find.byType(TextField), 'Household$index');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
        }        

        // Verifying the presence of 20 InputChip Texts
        var inputChipTextFinder = find.descendant(of: find.byType(InputChip), matching: find.byType(Text));
        expect(inputChipTextFinder, findsNWidgets(20));
      }
      );
  });


}