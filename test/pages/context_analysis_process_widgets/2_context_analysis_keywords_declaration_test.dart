import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/2_context_analysis_keywords_declaration.dart';

void main() 
{
    // 'CAKeywordsDeclaration Tests: \n'
    group('CAKeywordsDeclaration Tests: \n', 
    () 
    { 
      // 
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
                onKeywordsUpdatedCallbackFunction: (_){}
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
  });


}