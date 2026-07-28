import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/1_context_analysis_title_declaration.dart";

void main() {
  group("CATitleDeclaration Widget Tests: \n", () 
  {    
    // "Should render the correct text field hint"
    testWidgets("Should render the correct text field hint", 
    (WidgetTester tester) async 
    {
      // Building the widget
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CATitleDeclaration
            (
              analysisTitleWhenEdition: "",
              onAnalysisTitleUpdatedProcessCallbackFunction: (_){},
            )
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Getting the build context
      final context = tester.element(find.byType(Scaffold));
      var hintText = AppLocalizations.of(context)?.ca_process_title ?? "Issue with the context analysis process title";


      // Verifying the text field hint present
      expect(find.text(hintText), findsOneWidget);
    }
    );    
  }
);  

}