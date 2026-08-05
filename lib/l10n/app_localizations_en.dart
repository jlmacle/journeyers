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
      'Please enter one keyword at a time\nto describe the analysis.\n(+ Enter key)';

  @override
  String get ca_process_past_outcomes_text_field_hint =>
      'Please describe the past outcomes of the problem for the household, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the household.';

  @override
  String get ca_process_helping_household_text_field_hint =>
      'Please develop the reasons and potential impacts of an imbalance between faithfulness towards your own and consideration towards others.';

  @override
  String get ca_process_past_workplace_outcomes_text_field_hint =>
      'Please describe the past outcomes of the problem for the workplace, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the workplace and for the household.';

  @override
  String get ca_process_please_develop_text_field_hint => 'Please develop.';

  @override
  String get ca_process_please_describe_problems_text_field_hint =>
      'Please describe the problem(s) that the groups/teams are trying to solve.';

  @override
  String get ca_process_individual_perspective_title_question =>
      'As an individual:\nWhat problem\nam I trying to solve?';

  @override
  String get ca_process_individual_perspective_balance_issue_section_question =>
      'A Balance Issue?';

  @override
  String get ca_process_individual_perspective_balance_studies_household =>
      'To balance studies and household life?';

  @override
  String
  get ca_process_individual_perspective_balance_accessing_income_household =>
      'To balance accessing income and household life?';

  @override
  String
  get ca_process_individual_perspective_balance_earning_income_household =>
      'To balance earning an income and household life?';

  @override
  String
  get ca_process_individual_perspective_balance_helping_others_household =>
      'To balance helping others and household life?';

  @override
  String
  get ca_process_individual_perspective_workplace_issue_section_question =>
      'A Workplace Issue?';

  @override
  String get ca_process_individual_perspective_workplace_more_appreciated =>
      'To solve a need to be more appreciated at work?';

  @override
  String
  get ca_process_individual_perspective_workplace_to_remain_appreciated =>
      'To solve a need to remain appreciated at work?';

  @override
  String get ca_process_individual_perspective_legacy_issue_section_question =>
      'A Legacy Issue?';

  @override
  String get ca_process_individual_perspective_legacy_better_legacy =>
      'To have a better legacy to leave to my children/others?';

  @override
  String get ca_process_individual_perspective_another_issue_section_question =>
      'Is the issue\nof another type?';

  @override
  String get ca_process_group_perspective_title_question =>
      'As a member\nof groups/teams:\nWhat problem(s)\nare we trying to solve?';

  @override
  String get ca_process_group_perspective_problems =>
      'What problem(s)\nare my groups/teams\ntrying to solve?';

  @override
  String get ca_process_group_perspective_solving_same_problems =>
      'Am I trying to solve the same problem(s) as my groups/teams?';

  @override
  String get ca_process_group_perspective_harmony_home =>
      'Is entering the group problem-solving process consistent with harmony at home?';

  @override
  String get ca_process_group_perspective_appreciability_work =>
      'Is entering the group problem-solving process consistent with appreciability at work?';

  @override
  String get ca_process_group_perspective_earning_ability =>
      'Is entering the group problem-solving process consistent with my income earning ability?';

  @override
  String get ca_process_file_name_save_button_text_on_desktop =>
      'Click to save your data in CSV,\nspreadsheet-compatible format';

  @override
  String get ca_new_process_button =>
      'Please click to start\na new context analysis.';

  @override
  String get ca_unfilled_analysis_title => 'Untitled';

  @override
  String get ca_dashboard_title => 'Previous analyses';

  @override
  String get ca_preview_notes => 'Notes: ';

  @override
  String get ca_preview_answers => 'Answer(s): ';

  @override
  String get ca_preview_no_data_stored =>
      'No question checked and no data in the last text field.';

  @override
  String get segmented_button_yes => 'Yes';

  @override
  String get segmented_button_no => 'No';

  @override
  String get segmented_button_I_don_t_know => 'I don\'t know';

  @override
  String get gps_new_process_button =>
      'Please click to start\na new group problem-solving session.';

  @override
  String get gps_title_suffix => ' (gps)';

  @override
  String get gps_process_default_title => 'Problem To Solve';

  @override
  String get folder_picker_on_mobile =>
      'Please select or create a folder\nfor app storage.';

  @override
  String get file_name_process_text_field_hint_on_mobile =>
      'Please add the file name, without .';

  @override
  String get dashboard_sort_by_title => 'Sort by Title';

  @override
  String get dashboard_sort_by_date => 'Sort by Date';

  @override
  String get dashboard_filter_by_keywords => 'Filter by Keywords';

  @override
  String get dashboard_keywords => 'Keywords: ';

  @override
  String get dashboard_preview_mixed_languages_error_message =>
      'Did you save the data in a different language\nthan the current setting?\nIf so, please modify the setting\nto visualize the data.';

  @override
  String get dashboard_tooltip_preview => 'Preview';

  @override
  String get dashboard_tooltip_edit_session_data => 'Edit session data';

  @override
  String get dashboard_tooltip_edit_keywords => 'Edit Keywords';

  @override
  String get dashboard_tooltip_delete => 'Delete data';

  @override
  String get dashboard_tooltip_bulk_delete => 'Delete selected data';

  @override
  String get dashboard_preview_share_session_data_tooltip =>
      'Share session data';

  @override
  String get dashboard_preview_close_preview_tooltip =>
      'Please click to close the preview';

  @override
  String get dashboard_edit_title_sheet_label_text => 'Title Edition';

  @override
  String get dashboard_edit_title_sheet_text_field_hint =>
      'Please enter your title.';

  @override
  String get dashboard_edit_keywords_sheet_label_text =>
      'Keywords Edition (please separate with commas)';

  @override
  String get dashboard_edit_keywords_sheet_text_field_hint =>
      'Please enter your keywords.';

  @override
  String get text_lists_new_list_or_loading_list_page_title =>
      'Participants lists';

  @override
  String get text_lists_new_list_or_loading_list_page_subtitle =>
      'What would you like to do?';

  @override
  String get text_lists_new_list_or_loading_list_group_loading_option =>
      'To load a saved group?';

  @override
  String get text_lists_new_list_or_loading_list_new_group_option =>
      'To add a new group?';

  @override
  String get text_lists_new_list_title => 'New list';

  @override
  String get text_lists_new_list_keywords_title =>
      'Please enter keywords\nrelated to this group.';

  @override
  String get text_lists_new_list_placeholder_when_no_list_data =>
      'No names in the new group.\nPlease enter a name to add a participant to the group.';

  @override
  String get text_lists_new_list_text_field_hint =>
      'Please add a participant\'s name.';

  @override
  String get text_lists_new_list_content_already_saved_message =>
      'List content already saved.';

  @override
  String get text_lists_new_list_save_button_tooltip => 'Save list';

  @override
  String get text_lists_new_list_save_dialog_title => 'Save list';

  @override
  String get text_lists_new_list_save_dialog_text_field_label => 'List label';

  @override
  String get text_lists_new_list_save_dialog_text_field_hint =>
      'e.g. Our household members';

  @override
  String get l10n_keywords => 'Keywords';

  @override
  String get l10n_keywords_entry_text_field_hint =>
      'Please enter one keyword at a time.\n(+ Enter key)';

  @override
  String get l10n_keywords_overlay_close_button_tooltip =>
      'Please click to close the keywords declaration page';

  @override
  String get save_button_text => 'Save Changes';
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
      'Please enter one keyword at a time\nto describe the analysis.\n(+ Enter key)';

  @override
  String get ca_process_past_outcomes_text_field_hint =>
      'Please describe the past outcomes of the problem for the household, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the household.';

  @override
  String get ca_process_helping_household_text_field_hint =>
      'Please develop the reasons and potential impacts of an imbalance between faithfulness towards your own and consideration towards others.';

  @override
  String get ca_process_past_workplace_outcomes_text_field_hint =>
      'Please describe the past outcomes of the problem for the workplace, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the workplace and for the household.';

  @override
  String get ca_process_please_develop_text_field_hint => 'Please develop.';

  @override
  String get ca_process_please_describe_problems_text_field_hint =>
      'Please describe the problem(s) that the groups/teams are trying to solve.';

  @override
  String get ca_process_individual_perspective_title_question =>
      'As an individual:\nWhat problem\nam I trying to solve?';

  @override
  String get ca_process_individual_perspective_balance_issue_section_question =>
      'A Balance Issue?';

  @override
  String get ca_process_individual_perspective_balance_studies_household =>
      'To balance studies and household life?';

  @override
  String
  get ca_process_individual_perspective_balance_accessing_income_household =>
      'To balance accessing income and household life?';

  @override
  String
  get ca_process_individual_perspective_balance_earning_income_household =>
      'To balance earning an income and household life?';

  @override
  String
  get ca_process_individual_perspective_balance_helping_others_household =>
      'To balance helping others and household life?';

  @override
  String
  get ca_process_individual_perspective_workplace_issue_section_question =>
      'A Workplace Issue?';

  @override
  String get ca_process_individual_perspective_workplace_more_appreciated =>
      'To solve a need to be more appreciated at work?';

  @override
  String
  get ca_process_individual_perspective_workplace_to_remain_appreciated =>
      'To solve a need to remain appreciated at work?';

  @override
  String get ca_process_individual_perspective_legacy_issue_section_question =>
      'A Legacy Issue?';

  @override
  String get ca_process_individual_perspective_legacy_better_legacy =>
      'To have a better legacy to leave to my children/others?';

  @override
  String get ca_process_individual_perspective_another_issue_section_question =>
      'Is the issue\nof another type?';

  @override
  String get ca_process_group_perspective_title_question =>
      'As a member\nof groups/teams:\nWhat problem(s)\nare we trying to solve?';

  @override
  String get ca_process_group_perspective_problems =>
      'What problem(s)\nare my groups/teams\ntrying to solve?';

  @override
  String get ca_process_group_perspective_solving_same_problems =>
      'Am I trying to solve the same problem(s) as my groups/teams?';

  @override
  String get ca_process_group_perspective_harmony_home =>
      'Is entering the group problem-solving process consistent with harmony at home?';

  @override
  String get ca_process_group_perspective_appreciability_work =>
      'Is entering the group problem-solving process consistent with appreciability at work?';

  @override
  String get ca_process_group_perspective_earning_ability =>
      'Is entering the group problem-solving process consistent with my income earning ability?';

  @override
  String get ca_process_file_name_save_button_text_on_desktop =>
      'Click to save your data in CSV,\nspreadsheet-compatible format';

  @override
  String get ca_new_process_button =>
      'Please click to start\na new context analysis.';

  @override
  String get ca_unfilled_analysis_title => 'Untitled';

  @override
  String get ca_dashboard_title => 'Previous analyses';

  @override
  String get ca_preview_notes => 'Notes: ';

  @override
  String get ca_preview_answers => 'Answer(s): ';

  @override
  String get ca_preview_no_data_stored =>
      'No question checked and no data in the last text field.';

  @override
  String get segmented_button_yes => 'Yes';

  @override
  String get segmented_button_no => 'No';

  @override
  String get segmented_button_I_don_t_know => 'I don\'t know';

  @override
  String get gps_new_process_button =>
      'Please click to start\na new group problem-solving session.';

  @override
  String get gps_title_suffix => ' (gps)';

  @override
  String get gps_process_default_title => 'Problem To Solve';

  @override
  String get folder_picker_on_mobile =>
      'Please select or create a folder\nfor app storage.';

  @override
  String get file_name_process_text_field_hint_on_mobile =>
      'Please add the file name, without .';

  @override
  String get dashboard_sort_by_title => 'Sort by Title';

  @override
  String get dashboard_sort_by_date => 'Sort by Date';

  @override
  String get dashboard_filter_by_keywords => 'Filter by Keywords';

  @override
  String get dashboard_keywords => 'Keywords: ';

  @override
  String get dashboard_preview_mixed_languages_error_message =>
      'Did you save the data in a different language\nthan the current setting?\nIf so, please modify the setting\nto visualize the data.';

  @override
  String get dashboard_tooltip_preview => 'Preview';

  @override
  String get dashboard_tooltip_edit_session_data => 'Edit session data';

  @override
  String get dashboard_tooltip_edit_keywords => 'Edit Keywords';

  @override
  String get dashboard_tooltip_delete => 'Delete data';

  @override
  String get dashboard_tooltip_bulk_delete => 'Delete selected data';

  @override
  String get dashboard_preview_share_session_data_tooltip =>
      'Share session data';

  @override
  String get dashboard_preview_close_preview_tooltip =>
      'Please click to close the preview';

  @override
  String get dashboard_edit_title_sheet_label_text => 'Title Edition';

  @override
  String get dashboard_edit_title_sheet_text_field_hint =>
      'Please enter your title.';

  @override
  String get dashboard_edit_keywords_sheet_label_text =>
      'Keywords Edition (please separate with commas)';

  @override
  String get dashboard_edit_keywords_sheet_text_field_hint =>
      'Please enter your keywords.';

  @override
  String get text_lists_new_list_or_loading_list_page_title =>
      'Participants lists';

  @override
  String get text_lists_new_list_or_loading_list_page_subtitle =>
      'What would you like to do?';

  @override
  String get text_lists_new_list_or_loading_list_group_loading_option =>
      'To load a saved group?';

  @override
  String get text_lists_new_list_or_loading_list_new_group_option =>
      'To add a new group?';

  @override
  String get text_lists_new_list_title => 'New list';

  @override
  String get text_lists_new_list_keywords_title =>
      'Please enter keywords\nrelated to this group.';

  @override
  String get text_lists_new_list_placeholder_when_no_list_data =>
      'No names in the new group.\nPlease enter a name to add a participant to the group.';

  @override
  String get text_lists_new_list_text_field_hint =>
      'Please add a participant\'s name.';

  @override
  String get text_lists_new_list_content_already_saved_message =>
      'List content already saved.';

  @override
  String get text_lists_new_list_save_button_tooltip => 'Save list';

  @override
  String get text_lists_new_list_save_dialog_title => 'Save list';

  @override
  String get text_lists_new_list_save_dialog_text_field_label => 'List label';

  @override
  String get text_lists_new_list_save_dialog_text_field_hint =>
      'e.g. Our household members';

  @override
  String get l10n_keywords => 'Keywords';

  @override
  String get l10n_keywords_entry_text_field_hint =>
      'Please enter one keyword at a time.\n(+ Enter key)';

  @override
  String get l10n_keywords_overlay_close_button_tooltip =>
      'Please click to close the keywords declaration page';

  @override
  String get save_button_text => 'Save Changes';
}
