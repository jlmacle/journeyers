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
  /// **'Disclaimer:\nThis work is provided \'as is\' without warranty of any kind.\nThe author disclaims all liability for any use or misuse of the work.\n\nPlease note:\nThis is your first context analysis.\nThe dashboard will be displayed after data has been saved.\nPlease click to acknowledge.'**
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

  /// The 'Context analysis' bottom bar item label
  ///
  /// In en, this message translates to:
  /// **'Context analysis'**
  String get app_bottom_bar_item_context_analysis;

  /// The 'Group problem-solving' bottom bar item label
  ///
  /// In en, this message translates to:
  /// **'Group problem-solving'**
  String get app_bottom_bar_item_group_problem_solving;

  /// The title of the context analysis process
  ///
  /// In en, this message translates to:
  /// **'Context analysis'**
  String get ca_process_title;

  /// The l10n for 'Please click to toggle'
  ///
  /// In en, this message translates to:
  /// **'Please click to toggle'**
  String get ca_process_invitation_to_unfold_expansion_tile;

  /// The text field hint, for the title of the context analysis process
  ///
  /// In en, this message translates to:
  /// **'Please enter a title for this analysis.'**
  String get ca_process_title_text_field_hint;

  /// The text field hint, for the keywords of the context analysis process
  ///
  /// In en, this message translates to:
  /// **'Please enter one keyword at a time (+ Enter key).'**
  String get ca_process_keywords_text_field_hint;

  /// The text field hint, for the past outcomes of the problem for the household
  ///
  /// In en, this message translates to:
  /// **'Please describe the past outcomes of the problem for the household, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the household.'**
  String get ca_process_past_outcomes_text_field_hint;

  /// The text field hint, for the reasons and potential impacts of an imbalance between faithfulness towards your own and consideration towards others
  ///
  /// In en, this message translates to:
  /// **'Please develop the reasons and potential impacts of an imbalance between faithfulness towards your own and consideration towards others.'**
  String get ca_process_helping_household_text_field_hint;

  /// The text field hint, for the past outcomes of the problem for the workplace
  ///
  /// In en, this message translates to:
  /// **'Please describe the past outcomes of the problem for the workplace, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the workplace and for the household.'**
  String get ca_process_past_workplace_outcomes_text_field_hint;

  /// The text field hint inviting to develop
  ///
  /// In en, this message translates to:
  /// **'Please develop.'**
  String get ca_process_please_develop_text_field_hint;

  /// The text field hint inviting to describe the problem(s) that the groups/teams are trying to solve
  ///
  /// In en, this message translates to:
  /// **'Please describe the problem(s) that the groups/teams are trying to solve.'**
  String get ca_process_please_describe_problems_text_field_hint;

  /// The title question for the individual perspective
  ///
  /// In en, this message translates to:
  /// **'As an individual:\nWhat problem\nam I trying to solve?'**
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

  /// The section question for an issue of another type, in the individual perspective
  ///
  /// In en, this message translates to:
  /// **'Is the issue\nof another type?'**
  String get ca_process_individual_perspective_another_issue_section_question;

  /// The title question for the groups/teams perspective
  ///
  /// In en, this message translates to:
  /// **'As a member\nof groups/teams:\nWhat problem(s)\nare we trying to solve?'**
  String get ca_process_group_perspective_title_question;

  /// The question for the problem(s) the groups/teams are trying to solve
  ///
  /// In en, this message translates to:
  /// **'What problem(s)\nare my groups/teams\ntrying to solve?'**
  String get ca_process_group_perspective_problems;

  /// The question related to solving the same problem(s) as the groups/teams
  ///
  /// In en, this message translates to:
  /// **'Am I trying to solve the same problem(s) as my groups/teams?'**
  String get ca_process_group_perspective_solving_same_problems;

  /// The question related to the consistency with harmony at home
  ///
  /// In en, this message translates to:
  /// **'Is entering the group problem-solving process consistent with harmony at home?'**
  String get ca_process_group_perspective_harmony_home;

  /// The question related to the consistency with appreciability at work
  ///
  /// In en, this message translates to:
  /// **'Is entering the group problem-solving process consistent with appreciability at work?'**
  String get ca_process_group_perspective_appreciability_work;

  /// The question related to the consistency with earning ability
  ///
  /// In en, this message translates to:
  /// **'Is entering the group problem-solving process consistent with my income earning ability?'**
  String get ca_process_group_perspective_earning_ability;

  /// l10n for the save button text, in the c.a. process (on desktop)
  ///
  /// In en, this message translates to:
  /// **'Click to save your data in CSV,\nspreadsheet-compatible format'**
  String get ca_process_file_name_save_button_text_on_desktop;

  /// The text inviting to click to start a new context analysis.
  ///
  /// In en, this message translates to:
  /// **'Please click to start\na new context analysis.'**
  String get ca_new_process_button;

  /// The default title value for a context analysis
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get ca_unfilled_analysis_title;

  /// The dashboard title
  ///
  /// In en, this message translates to:
  /// **'Previous analyses'**
  String get ca_dashboard_title;

  /// l10n for Notes:
  ///
  /// In en, this message translates to:
  /// **'Notes: '**
  String get ca_preview_notes;

  /// l10n for Answer(s):
  ///
  /// In en, this message translates to:
  /// **'Answer(s): '**
  String get ca_preview_answers;

  /// l10n for 'No question checked and no data in the last text field.'
  ///
  /// In en, this message translates to:
  /// **'No question checked and no data in the last text field.'**
  String get ca_preview_no_data_stored;

  /// l10n for Yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get segmented_button_yes;

  /// l10n for No
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get segmented_button_no;

  /// l10n for I don't know
  ///
  /// In en, this message translates to:
  /// **'I don\'t know'**
  String get segmented_button_I_don_t_know;

  /// The text inviting to click to start a new group problem-solving session.
  ///
  /// In en, this message translates to:
  /// **'Please click to start\na new group problem-solving session.'**
  String get gps_new_process_button;

  /// The title suffix for a problem-solving session.
  ///
  /// In en, this message translates to:
  /// **' (gps)'**
  String get gps_title_suffix;

  /// The default title for a problem-solving session.
  ///
  /// In en, this message translates to:
  /// **'Problem To Solve'**
  String get gps_process_default_title;

  /// The default title when saving a problem-solving session.
  ///
  /// In en, this message translates to:
  /// **'Problem-Solving Session'**
  String get gps_process_default_saved_title;

  /// l10n for the 'Please click to add participants to the problem-solving session' tooltip
  ///
  /// In en, this message translates to:
  /// **'Please click to add participants to the problem-solving session'**
  String get gps_process_add_participants_tooltip;

  /// l10n for the 'Please click to edit the participants identifiers' tooltip
  ///
  /// In en, this message translates to:
  /// **'Please click to edit the participants identifiers'**
  String get gps_process_edit_identifiers_tooltip;

  /// l10n for 'Clear
  /// One'
  ///
  /// In en, this message translates to:
  /// **'Clear\nOne'**
  String get gps_process_edit_identifiers_clear_one;

  /// l10n for 'Clear
  /// All'
  ///
  /// In en, this message translates to:
  /// **'Clear\nAll'**
  String get gps_process_edit_identifiers_clear_all;

  /// l10n for the 'List of ideas' title
  ///
  /// In en, this message translates to:
  /// **'List of ideas'**
  String get gps_process_list_of_ideas_title;

  /// l10n for the 'No ideas added yet.' placeholder
  ///
  /// In en, this message translates to:
  /// **'No ideas added yet.'**
  String get gps_process_list_of_ideas_placeholder;

  /// l10n for the 'No ideas to save' snackbar message
  ///
  /// In en, this message translates to:
  /// **'No ideas to save'**
  String get gps_process_snackbar_message_no_ideas_to_save;

  /// The default title for the checklist-related widget.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get gps_process_checklist_title;

  /// l10n for the 'Please click to edit the title' tooltip
  ///
  /// In en, this message translates to:
  /// **'Please click to edit the title'**
  String get gps_process_edit_title_tooltip;

  /// The invitation before the checklist
  ///
  /// In en, this message translates to:
  /// **'Please consider postponing\nif incomplete'**
  String get gps_process_checklist_invitation;

  /// l10n for the 'Close checklist' tooltip
  ///
  /// In en, this message translates to:
  /// **'Close checklist'**
  String get gps_process_checklist_close_overlay_tooltip;

  /// Label for folder selection/creation, for app storage
  ///
  /// In en, this message translates to:
  /// **'Please select or create a folder\nfor app storage.'**
  String get folder_picker_on_mobile;

  /// The text field hint inviting to add a file name without extension
  ///
  /// In en, this message translates to:
  /// **'Please add the file name, without .'**
  String get file_name_process_text_field_hint_on_mobile;

  /// The 'Sort by Title' label
  ///
  /// In en, this message translates to:
  /// **'Sort by Title'**
  String get dashboard_sort_by_title;

  /// The 'Sort by Date' label
  ///
  /// In en, this message translates to:
  /// **'Sort by Date'**
  String get dashboard_sort_by_date;

  /// The 'Filter by Keywords' label
  ///
  /// In en, this message translates to:
  /// **'Filter by Keywords'**
  String get dashboard_filter_by_keywords;

  /// Text for the 'Keywords:' prefix for the dashboard items
  ///
  /// In en, this message translates to:
  /// **'Keywords:'**
  String get dashboard_keywords;

  /// l10n for the 'Delete selected data' text
  ///
  /// In en, this message translates to:
  /// **'Delete selected data'**
  String get dashboard_bulk_delete;

  /// Error message when previewing with a different interface language setting than the language used for the saved data
  ///
  /// In en, this message translates to:
  /// **'Did you save the data in a different language\nthan the current setting?\nIf so, please modify the setting\nto visualize the data.'**
  String get dashboard_preview_mixed_languages_error_message;

  /// l10n for the 'Preview' tooltip
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get dashboard_tooltip_preview;

  /// l10n for the 'Edit session data' tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit session data'**
  String get dashboard_tooltip_edit_session_data;

  /// l10n for the 'Edit Keywords' tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit Keywords'**
  String get dashboard_tooltip_edit_keywords;

  /// l10n for the 'Delete data' tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete data'**
  String get dashboard_tooltip_delete;

  /// l10n for the preview 'Share session data' tooltip
  ///
  /// In en, this message translates to:
  /// **'Share session data'**
  String get dashboard_preview_share_session_data_tooltip;

  /// l10n for the preview 'Close the preview' tooltip
  ///
  /// In en, this message translates to:
  /// **'Please click to close the preview'**
  String get dashboard_preview_close_preview_tooltip;

  /// l10n for the 'Title Edition' label text
  ///
  /// In en, this message translates to:
  /// **'Title Edition'**
  String get dashboard_edit_title_sheet_label_text;

  /// l10n for the 'Title Edition' text field hint
  ///
  /// In en, this message translates to:
  /// **'Please enter your title.'**
  String get dashboard_edit_title_sheet_text_field_hint;

  /// l10n for the 'Title cannot be empty' error message
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty'**
  String get dashboard_edit_title_error_empty_title;

  /// l10n for the 'Keywords Edition' label text
  ///
  /// In en, this message translates to:
  /// **'Keywords Edition (please separate with commas)'**
  String get dashboard_edit_keywords_sheet_label_text;

  /// l10n for the 'Keywords Edition' text field hint
  ///
  /// In en, this message translates to:
  /// **'Please enter your keywords.'**
  String get dashboard_edit_keywords_sheet_text_field_hint;

  /// l10n for the 'Session data saved' snackbar message
  ///
  /// In en, this message translates to:
  /// **'Session data saved'**
  String get dashboard_snackbar_message_session_saved_successfully;

  /// l10n for the 'Data deleted' snackbar message
  ///
  /// In en, this message translates to:
  /// **'Data deleted'**
  String get dashboard_snackbar_message_data_deleted;

  /// l10n for the 'Keywords updated' snackbar message
  ///
  /// In en, this message translates to:
  /// **'Keywords updated'**
  String get dashboard_snackbar_message_keywords_updated;

  /// The default title for the new list or loading list page.
  ///
  /// In en, this message translates to:
  /// **'Participants lists'**
  String get text_lists_new_list_or_loading_list_page_title;

  /// The default subtitle for the new list or loading list page.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get text_lists_new_list_or_loading_list_page_subtitle;

  /// The loading option text for the new list or loading list page.
  ///
  /// In en, this message translates to:
  /// **'To load a saved group?'**
  String get text_lists_new_list_or_loading_list_group_loading_option;

  /// The new group option text for the new list or loading list page.
  ///
  /// In en, this message translates to:
  /// **'To add a new group?'**
  String get text_lists_new_list_or_loading_list_new_group_option;

  /// The title of the new list page.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get text_lists_new_list_title;

  /// The title of the new list page keywords overlay.
  ///
  /// In en, this message translates to:
  /// **'Please enter keywords\nrelated to this group.'**
  String get text_lists_new_list_keywords_title;

  /// The placeholder text when no participant's name has been added to the new group
  ///
  /// In en, this message translates to:
  /// **'No names in the new group.\nPlease enter a name\nto add a participant to the group.'**
  String get text_lists_new_list_placeholder_when_no_list_data;

  /// The text field hint for adding a participant's name.
  ///
  /// In en, this message translates to:
  /// **'Please add a participant\'s name.'**
  String get text_lists_new_list_text_field_hint;

  /// The message when a list content is already saved
  ///
  /// In en, this message translates to:
  /// **'List content already saved.'**
  String get text_lists_new_list_content_already_saved_message;

  /// l10n for the save button tooltip
  ///
  /// In en, this message translates to:
  /// **'Save list'**
  String get text_lists_new_list_save_button_tooltip;

  /// l10n for the save dialog title
  ///
  /// In en, this message translates to:
  /// **'Save list'**
  String get text_lists_new_list_save_dialog_title;

  /// l10n for the save dialog text field label
  ///
  /// In en, this message translates to:
  /// **'List label'**
  String get text_lists_new_list_save_dialog_text_field_label;

  /// l10n for the save dialog text field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Our household members'**
  String get text_lists_new_list_save_dialog_text_field_hint;

  /// The message when the list name is empty at saving time
  ///
  /// In en, this message translates to:
  /// **'Label cannot be empty.'**
  String get text_lists_new_list_empty_list_name_message;

  /// The message, at saving time, when a list name has already been used.
  ///
  /// In en, this message translates to:
  /// **' already exists.\nPlease choose another label.'**
  String get text_lists_new_list_same_list_name_message;

  /// l10n for the 'click to go to the previous page' tooltip
  ///
  /// In en, this message translates to:
  /// **'Please click to go to the previous page'**
  String get text_lists_new_list_close_tooltip;

  /// The title for the participants lists dashboard
  ///
  /// In en, this message translates to:
  /// **'Stored participants lists'**
  String get text_lists_dashboard_title;

  /// The 'List sort' label
  ///
  /// In en, this message translates to:
  /// **'List sort'**
  String get text_lists_dashboard_sort_by_list_name;

  /// l10n for the 'List Name Edition' label text
  ///
  /// In en, this message translates to:
  /// **'List Name Edition'**
  String get text_lists_dashboard_edit_list_name_sheet_label_text;

  /// l10n for the 'List Name Edition' text field hint
  ///
  /// In en, this message translates to:
  /// **'Please enter a list name'**
  String get text_lists_dashboard_edit_list_name_sheet_text_field_hint;

  /// l10n for the 'Participants Edition' label text
  ///
  /// In en, this message translates to:
  /// **'Participants Edition (please separate with commas)'**
  String get text_lists_dashboard_edit_participants_sheet_label_text;

  /// l10n for the 'Participants Edition' text field hint
  ///
  /// In en, this message translates to:
  /// **'Please enter the participants.'**
  String get text_lists_dashboard_edit_participants_sheet_text_field_hint;

  /// l10n for the list loading button text
  ///
  /// In en, this message translates to:
  /// **'Please click to load'**
  String get text_lists_dashboard_list_loading_button_text;

  /// l10n for 'Keywords'
  ///
  /// In en, this message translates to:
  /// **'Keywords'**
  String get l10n_keywords;

  /// l10n for 'Delete'
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get l10n_delete;

  /// l10n for 'Cancel'
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get l10n_cancel;

  /// l10n for 'Save'
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get l10n_save;

  /// l10n for 'Done'
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get l10n_done;

  /// l10n for the keywords entry text field hint
  ///
  /// In en, this message translates to:
  /// **'Please enter one keyword at a time.\n(+ Enter key)'**
  String get l10n_keywords_entry_text_field_hint;

  /// l10n for the keywords overlay close button tooltip
  ///
  /// In en, this message translates to:
  /// **'Please click to close the keywords declaration page'**
  String get l10n_keywords_overlay_close_button_tooltip;

  /// l10n for the save_button text
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_button_text;
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
