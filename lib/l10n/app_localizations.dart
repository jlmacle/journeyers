import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'US'),
    Locale('fr'),
    Locale('fr', 'FR'),
  ];

  /// The title for the app
  ///
  /// In en, this message translates to:
  /// **'Journeyers'**
  String get app_title;

  /// The subtitle for the app
  ///
  /// In en, this message translates to:
  /// **'What story will we leave\nfor our loved ones to tell?'**
  String get app_sub_title;

  /// The information message that a newly installed app should display.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer:\nThis work is provided \'as is\'\nwithout warranty of any kind.\nThe author disclaims all liability\nfor any use or misuse of the work.\n\nPlease note:\nThis is your first\ncontext analysis.\nThe dashboard will be displayed\nafter data has been saved.\nPlease click to acknowledge.'**
  String get app_start_msg;

  /// The name of the English language, in English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get app_lang_en;

  /// The name of the French language, in English
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get app_lang_fr;

  /// The title of the context analysis process
  ///
  /// In en, this message translates to:
  /// **'Context analysis'**
  String get ca_process_title;

  /// The text field hint, for the title of the context analysis process
  ///
  /// In en, this message translates to:
  /// **'Please enter a title for this analysis.'**
  String get ca_process_title_text_field_hint;

  /// The text field hint, for the keywords of the context analysis process
  ///
  /// In en, this message translates to:
  /// **'Please enter keywords\nto describe the analysis.\n(+ Enter key)'**
  String get ca_process_keywords_text_field_hint;

  /// The text field hint, for the past outcomes for the household
  ///
  /// In en, this message translates to:
  /// **'Please describe the past outcomes for the household, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the household.'**
  String get ca_process_past_outcomes_text_field_hint;

  /// The text field hint, for the reasons and potential impacts of an imbalance between faithfulness towards your own and consideration towards others
  ///
  /// In en, this message translates to:
  /// **'Please develop the reasons and potential impacts of an imbalance between faithfulness towards your own and consideration towards others.'**
  String get ca_process_helping_household_text_field_hint;

  /// The text field hint, for the past outcomes for the workplace
  ///
  /// In en, this message translates to:
  /// **'Please describe the past outcomes for the workplace, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the workplace and for the household.'**
  String get ca_process_past_workplace_outcomes_text_field_hint;

  /// The text field hint inviting to develop
  ///
  /// In en, this message translates to:
  /// **'Please develop.'**
  String get ca_process_please_develop_text_field_hint;

  /// The title question for the individual perspective
  ///
  /// In en, this message translates to:
  /// **'As an individual:\nWhat problem am I trying to solve?'**
  String get ca_process_individual_perspective_title_question;

  /// The section question for the balance issue, in the individual perspective
  ///
  /// In en, this message translates to:
  /// **'A Balance Issue?'**
  String get ca_process_individual_perspective_balance_issue_section_question;

  /// The studies-household life balance question, in the individual perspective
  ///
  /// In en, this message translates to:
  /// **'To balance studies and household life?'**
  String get ca_process_individual_perspective_balance_studies_household;

  /// The accessing income-household life balance question, in the individual perspective
  ///
  /// In en, this message translates to:
  /// **'To balance accessing income and household life?'**
  String
  get ca_process_individual_perspective_balance_accessing_income_household;

  /// The earning income-household life balance question, in the individual perspective
  ///
  /// In en, this message translates to:
  /// **'To balance earning an income and household life?'**
  String get ca_process_individual_perspective_balance_earning_income_household;

  /// The helping others-household life balance question, in the individual perspective
  ///
  /// In en, this message translates to:
  /// **'To balance helping others and household life?'**
  String get ca_process_individual_perspective_balance_helping_others_household;

  /// The section question for the workplace issue, in the individual perspective
  ///
  /// In en, this message translates to:
  /// **'A Workplace Issue?'**
  String get ca_process_individual_perspective_workplace_issue_section_question;

  /// The more-appreciated-at-work question, in the individual perspective
  ///
  /// In en, this message translates to:
  /// **'To solve a need to be more appreciated at work?'**
  String get ca_process_individual_perspective_workplace_more_appreciated;

  /// The to-remain-appreciated-at-work question, in the individual perspective
  ///
  /// In en, this message translates to:
  /// **'To solve a need to remain appreciated at work?'**
  String get ca_process_individual_perspective_workplace_to_remain_appreciated;

  /// The section question for the legacy issue, in the individual perspective
  ///
  /// In en, this message translates to:
  /// **'A Legacy Issue?'**
  String get ca_process_individual_perspective_legacy_issue_section_question;

  /// The better legacy question, in the individual perspective
  ///
  /// In en, this message translates to:
  /// **'To have a better legacy to leave to my children/others?'**
  String get ca_process_individual_perspective_legacy_better_legacy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return AppLocalizationsEnUs();
        }
        break;
      }
    case 'fr':
      {
        switch (locale.countryCode) {
          case 'FR':
            return AppLocalizationsFrFr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
