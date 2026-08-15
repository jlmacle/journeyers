import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:path/path.dart" as p;
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/utils/generic/dev/test_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/utils/generic/text_fields/text_field_utils.dart";
import "package:journeyers/utils/project_specific/text_fields/text_field_utils.dart" as tfu_proj;
import "package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_sanitized_and_checked_using_a_blacklist.dart";

void main() {
  const textWithQuote = 'Perse"verance';
  const textWithDot = ".Legacy";
  const fileNameBlacklisted = "a.csv";
  const textValid = "Context analysis";

  // ── TESTS PREPARATION AND CLEANUP ─────────────────────────────────────────────────────────────
  Directory? testTmpDir;

  setUp(() async {
    // Creating a temporary folder to store test files
    testTmpDir = await Directory.systemTemp.createTemp("TextFieldSanitizedAndCheckedUsingABlackList_test_");
    PathProviderPlatform.instance = PathProviderPlatformRedirectForTesting(testTmpDir!.path);
  });

  // "This function will be called after each test is run. 
  // The body may be asynchronous; if so, it must return a Future."
  tearDown(() async {
    if (testTmpDir!.existsSync()) {
      // Deleting the temporary folder created to store the files
      await testTmpDir!.delete(recursive: true);
    }
  });
  
  group("TextFieldChecked Tests:\n", () {
   testWidgets("Should show an error message when a sanitizing function (containsAStraightQuote) returns true", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TextFieldSanitizedAndCheckedUsingABlackList(
              textFieldStartValue: "",
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageStyle: analysisTextFieldErrorMessageStyle,
              onTextFieldValueChangedCallbackFunction: (_) {},
              stringSanitizerBundlesErrorsMapping: tfu_proj.TextFieldStringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForCA,
             blacklistingFunctionsErrorsMapping: const {},
            ),
          ),
        ),
      );

      // Entering text to trigger "containsStraightQuote"
      await tester.enterText(find.byType(TextField), textWithQuote);
      await tester.pumpAndSettle();

      // Verifying error message is rendered
      expect(find.text(TextFieldUtils.errorContainsAStraightQuote), findsOneWidget);
    });

    testWidgets("Should show an error message when a sanitizing function (containsADot) returns true", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TextFieldSanitizedAndCheckedUsingABlackList(
              textFieldStartValue: "",
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageStyle: analysisTextFieldErrorMessageStyle,
              onTextFieldValueChangedCallbackFunction: (_) {},
              stringSanitizerBundlesErrorsMapping: tfu_proj.TextFieldStringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForFileNames,
              blacklistingFunctionsErrorsMapping: const {},
            ),
          ),
        ),
      );

      // Entering text to trigger "containsADotError"
      await tester.enterText(find.byType(TextField), textWithDot);
      await tester.pumpAndSettle();

      // Verifying error message is rendered
      expect(find.text(TextFieldUtils.errorContainsADot), findsOneWidget);
    });
    
    testWidgets("Should show an error message when a blacklist check is positive (simple blacklist check)", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TextFieldSanitizedAndCheckedUsingABlackList(
              textFieldStartValue: "",
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageFieldKey: GlobalKey(),
              errorMessageStyle: analysisTextFieldErrorMessageStyle,
              onTextFieldValueChangedCallbackFunction: (_) {},
              stringSanitizerBundlesErrorsMapping: const {},
              blacklistingFunctionsErrorsMapping: TextFieldUtils.simpleBlacklistingFunctionErrorMapping,
            ),
          ),
        ),
      );

      // Entering the text to search in the blacklist
      await tester.enterText(find.byType(TextField), fileNameBlacklisted);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // Verifying error message is rendered
      expect(find.text(TextFieldUtils.errorTextBlacklisted), findsOneWidget);
    });

    testWidgets("Should show an error message when a blacklist check is positive (existant CSV file name)", 
    (WidgetTester tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Setting mock values for SharedPreferences
      SharedPreferences.setMockInitialValues
      ({
        // Temporary test dir as application folder path
        "applicationFolderPath": testTmpDir!.path
      });

      File csvFile1 = File(p.join(testTmpDir!.path, "file1.csv"));
      csvFile1.createSync();

      File csvFile2 = File(p.join(testTmpDir!.path, "file2.csv"));
      csvFile2.createSync();

      await du.getStoredFileNamesOnMobile(testDirectoryPath: testTmpDir!.path, fileExtension: TextFieldUtils.extensionCSV);

      var fileNameWithExtensionBlacklisted = "file1";

      // Pumping the widget
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TextFieldSanitizedAndCheckedUsingABlackList(
              textFieldStartValue: "",
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageFieldKey: GlobalKey(),
              errorMessageStyle: analysisTextFieldErrorMessageStyle,
              onTextFieldValueChangedCallbackFunction: (_) {},
              stringSanitizerBundlesErrorsMapping: const {},
              blacklistingFunctionsErrorsMapping: tfu_proj.TextFieldStringSanitizerBundlesErrorsMappings.blacklistingFunctionsErrorsMappingForCSVFileNames,
            ),
          ),
        ),
      );

      // Entering the text to search in the blacklist
      await tester.enterText(find.byType(TextField), fileNameWithExtensionBlacklisted);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // Verifying error message rendered
      expect(find.text(TextFieldUtils.errorFileNameAlreadyUsed), findsOneWidget);
    });

    testWidgets("Should call onTextFieldValueSubmittedCallbackFunction if input is valid", (WidgetTester tester) async {
      String submittedValue = "";

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TextFieldSanitizedAndCheckedUsingABlackList(
              textFieldStartValue: "",
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageStyle: analysisTextFieldErrorMessageStyle,
              onTextFieldValueChangedCallbackFunction: (val) => submittedValue = val,
              stringSanitizerBundlesErrorsMapping: tfu_proj.TextFieldStringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForCA,
              blacklistingFunctionsErrorsMapping: const{},
            ),
          ),
        ),
      );

      // Entering valid text
      await tester.enterText(find.byType(TextField), textValid);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, equals(textValid));
    });

  });
}