import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_form_misc_constants.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/1_context_analysis_title_declaration.dart";

void main() {
  group("CATitleDeclaration Widget Tests: \n", () 
  {
    const String hintText = CAFormMiscConstants.caTitleDeclarationHintText;

    // "Should render the correct text field hint"
    testWidgets("Should render the correct text field hint", 
    (WidgetTester tester) async 
    {
      // Building the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CATitleDeclaration
            (
              analysisTitleWhenEdition: "",
              onAnalysisTitleUpdatedProcessCallbackFunction: (_){},
            )
          ),
        ),
      );

      // Verifying the text field hint present
      expect(find.text(hintText), findsOneWidget);
    }
    );    
  }
);  

}