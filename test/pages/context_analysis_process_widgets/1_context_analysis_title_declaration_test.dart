import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_ca_strings.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/1_context_analysis_title_declaration.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

void main() {
  group("CATitleDeclaration Widget Tests: \n", () 
  {    
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

      // Getting the localized strings
      var context = tester.element(find.byType(Scaffold).first);
      LocalizedCAStrings lca = .new(context);
      
      // Getting the hint text
      var hintText = "";
      /// Consider avoiding static references to this singleton through
      /// [PlatformDispatcher.instance] and instead prefer using a binding for
      /// dependency resolution such as `WidgetsBinding.instance.platformDispatcher`.
      /// See [PlatformDispatcher.instance] for more information about why this is
      /// preferred.
      Locale? currentLocale = WidgetsBinding.instance.platformDispatcher.locale;
      var localeLanguageCode = currentLocale.languageCode;
      if (testingDebug) pu.printd("Testing Debug: operatingSystem: ${Platform.operatingSystem}");
      if (testingDebug) pu.printd("Testing Debug: localeLanguageCode: $localeLanguageCode");

      switch(localeLanguageCode.toLowerCase())
      {
        case("en"): { hintText = "Please enter a title for this analysis."; }
        case("fr"): { hintText = "Veuillez renseigner le titre\nde cette analyse."; }        
      }
      if (testingDebug) pu.printd("Testing Debug: hintText: $hintText"); 

      // Verifying consistency between hard-coded string and localized string
      expect(hintText, lca.caTitleTextFieldHint);     

      // Verifying the text field hint present
      expect(find.text(hintText), findsOneWidget);
    }
    );    
  
    testWidgets("Starts not autofocused (to avoid the keyboard on mobile)", 
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

      // Getting the text field
      var textFieldFinder = find.byType(TextField);
      var textField = tester.widget<TextField>(textFieldFinder);
      expect (textField.autofocus, false);
    }
    );    
  
    testWidgets("The title length has a limit of 150 characters", 
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

      expect (find.textContaining("/150"), findsOne);
    }
    );    
  
  }
);  

}