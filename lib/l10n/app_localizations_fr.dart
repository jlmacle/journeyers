// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get app_title => 'Témoignages';

  @override
  String get app_sub_title =>
      'Quelle histoire laisserons-nous\nà nos proches ?';

  @override
  String get app_start_msg =>
      'Ceci est votre première analyse de contexte.\nLe tableau de bord s\'affichera une fois que des données auront été enregistrées.\nCliquez pour fermer.';

  @override
  String get app_lang_en => 'Anglais';

  @override
  String get app_lang_fr => 'Français';

  @override
  String get ca_process_title => 'Analyse du contexte';

  @override
  String get ca_process_title_text_field_hint =>
      'Veuillez renseigner le titre\nde cette analyse.';

  @override
  String get ca_process_keywords_text_field_hint =>
      'Veuillez renseigner des mots-clés\npour cette analyse.';

  @override
  String get ca_process_past_outcomes_text_field_hint =>
      'Veuillez décrire les conséquences du problème, si des membres du foyer ont été en dehors de leur zone de confort pendant trop longtemps, et une situation de vie qui serait plus favorable au foyer.';

  @override
  String get ca_process_individual_perspective_title_question =>
      'En tant qu\'individu:\nQuel problème dois-je résoudre ?';

  @override
  String get ca_process_individual_perspective_balance_issue_section_question =>
      'Un problème d\'équilibre ?';

  @override
  String get ca_process_individual_perspective_balance_studies_household =>
      'Équilibre entre les études et la vie de famille ?';

  @override
  String
  get ca_process_individual_perspective_balance_accessing_income_household =>
      'Équilibre entre l\'accès à l\'emploi et la vie de famille ?';

  @override
  String
  get ca_process_individual_perspective_balance_earning_income_household =>
      'Équilibre entre maintenir un revenu et la vie de famille ?';
}

/// The translations for French, as used in France (`fr_FR`).
class AppLocalizationsFrFr extends AppLocalizationsFr {
  AppLocalizationsFrFr() : super('fr_FR');

  @override
  String get app_title => 'Témoignages';

  @override
  String get app_sub_title =>
      'Quelle histoire laisserons-nous\nà nos proches ?';

  @override
  String get app_start_msg =>
      'Ceci est votre première analyse de contexte.\nLe tableau de bord s\'affichera une fois que des données auront été enregistrées.\nCliquez pour fermer.';

  @override
  String get app_lang_en => 'Anglais';

  @override
  String get app_lang_fr => 'Français';

  @override
  String get ca_process_title => 'Analyse du contexte';

  @override
  String get ca_process_title_text_field_hint =>
      'Veuillez renseigner le titre\nde cette analyse.';

  @override
  String get ca_process_keywords_text_field_hint =>
      'Veuillez renseigner des mots-clés\npour cette analyse.';

  @override
  String get ca_process_past_outcomes_text_field_hint =>
      'Veuillez décrire les conséquences du problème, si des membres du foyer ont été en dehors de leur zone de confort pendant trop longtemps, et une situation de vie qui serait plus favorable au foyer.';

  @override
  String get ca_process_individual_perspective_title_question =>
      'En tant qu\'individu:\nQuel problème dois-je résoudre ?';

  @override
  String get ca_process_individual_perspective_balance_issue_section_question =>
      'Un problème d\'équilibre ?';

  @override
  String get ca_process_individual_perspective_balance_studies_household =>
      'Équilibre entre les études et la vie de famille ?';

  @override
  String
  get ca_process_individual_perspective_balance_accessing_income_household =>
      'Équilibre entre l\'accès à l\'emploi et la vie de famille ?';

  @override
  String
  get ca_process_individual_perspective_balance_earning_income_household =>
      'Équilibre entre maintenir un revenu et la vie de famille ?';
}
