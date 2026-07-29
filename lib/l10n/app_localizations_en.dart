// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Journeyers';

  @override
  String get app_sub_title =>
      'What story will we leave\nfor our loved ones to tell?';

  @override
  String get app_start_msg =>
      'Disclaimer:\nThis work is provided \'as is\'\nwithout warranty of any kind.\nThe author disclaims all liability\nfor any use or misuse of the work.\n\nPlease note:\nThis is your first\ncontext analysis.\nThe dashboard will be displayed\nafter data has been saved.\nPlease click to acknowledge.';

  @override
  String get app_lang_en => 'English';

  @override
  String get app_lang_fr => 'French';

  @override
  String get ca_process_title => 'Context analysis';

  @override
  String get ca_process_title_text_field_hint =>
      'Please enter a title for this analysis.';

  @override
  String get ca_process_keywords_text_field_hint =>
      'Please enter keywords\nto describe the analysis.\n(+ Enter key)';

  @override
  String get ca_process_individual_perspective_title_question =>
      'As an individual:\nWhat problem am I trying to solve?';

  @override
  String get ca_process_individual_perspective_balance_issue_section_question =>
      'A Balance Issue?';

  @override
  String get ca_process_individual_perspective_balance_studies_household =>
      'To balance studies and household life?';
}

/// The translations for English, as used in the United States (`en_US`).
class AppLocalizationsEnUs extends AppLocalizationsEn {
  AppLocalizationsEnUs() : super('en_US');

  @override
  String get app_title => 'Journeyers';

  @override
  String get app_sub_title =>
      'What story will we leave\nfor our loved ones to tell?';

  @override
  String get app_start_msg =>
      'Disclaimer:\nThis work is provided \'as is\'\nwithout warranty of any kind.\nThe author disclaims all liability\nfor any use or misuse of the work.\n\nPlease note:\nThis is your first\ncontext analysis.\nThe dashboard will be displayed\nafter data has been saved.\nPlease click to acknowledge.';

  @override
  String get app_lang_en => 'English';

  @override
  String get app_lang_fr => 'French';

  @override
  String get ca_process_title => 'Context analysis';

  @override
  String get ca_process_title_text_field_hint =>
      'Please enter a title for this analysis.';

  @override
  String get ca_process_keywords_text_field_hint =>
      'Please enter keywords\nto describe the analysis.\n(+ Enter key)';

  @override
  String get ca_process_individual_perspective_title_question =>
      'As an individual:\nWhat problem am I trying to solve?';

  @override
  String get ca_process_individual_perspective_balance_issue_section_question =>
      'A Balance Issue?';

  @override
  String get ca_process_individual_perspective_balance_studies_household =>
      'To balance studies and household life?';
}
