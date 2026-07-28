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
  String get ca_process_individual_perspective_title_question =>
      'En tant qu\'individu:\nQuel problème dois-je résoudre?';

  @override
  String get ca_process_individual_perspective_balance_issue_section_question =>
      'Un problème d\'équilibre?';
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
  String get ca_process_individual_perspective_title_question =>
      'En tant qu\'individu:\nQuel problème dois-je résoudre?';

  @override
  String get ca_process_individual_perspective_balance_issue_section_question =>
      'Un problème d\'équilibre?';
}
