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
      'Veuillez renseigner des mots-clés\npour cette analyse.\n(+ Touche Entrée)';

  @override
  String get ca_process_past_outcomes_text_field_hint =>
      'Veuillez décrire les conséquences du problème, si des membres du foyer ont été en dehors de leur zone de confort pendant trop longtemps, et une situation de vie qui serait plus favorable aux membres du foyer.';

  @override
  String get ca_process_helping_household_text_field_hint =>
      'Veuillez développer les raisons, et les impacts potentiels, d\'un déséquilibre entre fidélité envers votre famille et considération envers les autres.';

  @override
  String get ca_process_past_workplace_outcomes_text_field_hint =>
      'Veuillez décrire les conséquences du problème, si des membres du lieu de travail ont été en dehors de leur zone de confort pendant trop longtemps, et une situation de vie qui serait plus favorable aux collègues du lieu de travail et aux membres du foyer.';

  @override
  String get ca_process_please_develop_text_field_hint =>
      'Veuillez développer.';

  @override
  String get ca_process_please_describe_problems_text_field_hint =>
      'Veuillez décrire le(s) problème(s) que vos groupes/équipes essayent de résoudre.';

  @override
  String get ca_process_individual_perspective_title_question =>
      'En tant qu\'individu:\nQuel problème\ndois-je résoudre ?';

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

  @override
  String
  get ca_process_individual_perspective_balance_helping_others_household =>
      'Équilibre entre aider les autres et la vie de famille ?';

  @override
  String
  get ca_process_individual_perspective_workplace_issue_section_question =>
      'Un problème au travail ?';

  @override
  String get ca_process_individual_perspective_workplace_more_appreciated =>
      'Le besoin d\'être plus apprécié(e) au travail ?';

  @override
  String
  get ca_process_individual_perspective_workplace_to_remain_appreciated =>
      'Le besoin de rester apprécié(e) au travail ?';

  @override
  String get ca_process_individual_perspective_legacy_issue_section_question =>
      'Un problème\navec mon histoire de vie ?';

  @override
  String get ca_process_individual_perspective_legacy_better_legacy =>
      'Avoir une histoire de vie de meilleure qualité à laisser à mes enfants/aux autres ?';

  @override
  String get ca_process_individual_perspective_another_issue_section_question =>
      'Est-ce un autre type\nde problème ?';

  @override
  String get ca_process_group_perspective_title_question =>
      'En tant que membre\nde groupes/équipes:\nQuel(s) problème(s)\ndevons-nous résoudre ?';

  @override
  String get ca_process_group_perspective_problems =>
      'Quel(s) problème(s)\nnos groupes/équipes\nessayent de résoudre ?';

  @override
  String get ca_process_group_perspective_solving_same_problems =>
      'Est-ce que j\'essaie de résoudre les mêmes problèmes que mes groupes/équipes ?';

  @override
  String get ca_process_group_perspective_harmony_home =>
      'Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec l\'harmonie dans le foyer ?';

  @override
  String get ca_process_group_perspective_appreciability_work =>
      'Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec rester apprécié au travail ?';

  @override
  String get ca_process_group_perspective_earning_ability =>
      'Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec ma capacité à générer un revenu ?';

  @override
  String get segmented_button_yes => 'Oui';

  @override
  String get segmented_button_no => 'Non';

  @override
  String get segmented_button_I_don_t_know => 'Je ne sais pas';

  @override
  String get folder_picker_on_mobile =>
      'Veuillez sélectionner,\nou créer un dossier,\npour stocker vos données.';

  @override
  String get file_name_process_text_field_hint =>
      'Veuillez entrer un nom de fichier, sans .';

  @override
  String get ca_new_process_button =>
      'Veuillez cliquer pour démarrer\nune nouvelle analyse de contexte.';

  @override
  String get ca_unfilled_analysis_title => 'Sans titre';

  @override
  String get ca_dashboard_title => 'Analyses précédentes';

  @override
  String get ca_dashboard_sort_by_title => 'Tri par titre';

  @override
  String get ca_dashboard_sort_by_date => 'Tri par date';
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
      'Veuillez renseigner des mots-clés\npour cette analyse.\n(+ Touche Entrée)';

  @override
  String get ca_process_past_outcomes_text_field_hint =>
      'Veuillez décrire les conséquences du problème, si des membres du foyer ont été en dehors de leur zone de confort pendant trop longtemps, et une situation de vie qui serait plus favorable aux membres du foyer.';

  @override
  String get ca_process_helping_household_text_field_hint =>
      'Veuillez développer les raisons, et les impacts potentiels, d\'un déséquilibre entre fidélité envers votre famille et considération envers les autres.';

  @override
  String get ca_process_past_workplace_outcomes_text_field_hint =>
      'Veuillez décrire les conséquences du problème, si des membres du lieu de travail ont été en dehors de leur zone de confort pendant trop longtemps, et une situation de vie qui serait plus favorable aux collègues du lieu de travail et aux membres du foyer.';

  @override
  String get ca_process_please_develop_text_field_hint =>
      'Veuillez développer.';

  @override
  String get ca_process_please_describe_problems_text_field_hint =>
      'Veuillez décrire le(s) problème(s) que vos groupes/équipes essayent de résoudre.';

  @override
  String get ca_process_individual_perspective_title_question =>
      'En tant qu\'individu:\nQuel problème\ndois-je résoudre ?';

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

  @override
  String
  get ca_process_individual_perspective_balance_helping_others_household =>
      'Équilibre entre aider les autres et la vie de famille ?';

  @override
  String
  get ca_process_individual_perspective_workplace_issue_section_question =>
      'Un problème au travail ?';

  @override
  String get ca_process_individual_perspective_workplace_more_appreciated =>
      'Le besoin d\'être plus apprécié(e) au travail ?';

  @override
  String
  get ca_process_individual_perspective_workplace_to_remain_appreciated =>
      'Le besoin de rester apprécié(e) au travail ?';

  @override
  String get ca_process_individual_perspective_legacy_issue_section_question =>
      'Un problème\navec mon histoire de vie ?';

  @override
  String get ca_process_individual_perspective_legacy_better_legacy =>
      'Avoir une histoire de vie de meilleure qualité à laisser à mes enfants/aux autres ?';

  @override
  String get ca_process_individual_perspective_another_issue_section_question =>
      'Est-ce un autre type\nde problème ?';

  @override
  String get ca_process_group_perspective_title_question =>
      'En tant que membre\nde groupes/équipes:\nQuel(s) problème(s)\ndevons-nous résoudre ?';

  @override
  String get ca_process_group_perspective_problems =>
      'Quel(s) problème(s)\nnos groupes/équipes\nessayent de résoudre ?';

  @override
  String get ca_process_group_perspective_solving_same_problems =>
      'Est-ce que j\'essaie de résoudre les mêmes problèmes que mes groupes/équipes ?';

  @override
  String get ca_process_group_perspective_harmony_home =>
      'Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec l\'harmonie dans le foyer ?';

  @override
  String get ca_process_group_perspective_appreciability_work =>
      'Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec rester apprécié au travail ?';

  @override
  String get ca_process_group_perspective_earning_ability =>
      'Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec ma capacité à générer un revenu ?';

  @override
  String get segmented_button_yes => 'Oui';

  @override
  String get segmented_button_no => 'Non';

  @override
  String get segmented_button_I_don_t_know => 'Je ne sais pas';

  @override
  String get folder_picker_on_mobile =>
      'Veuillez sélectionner,\nou créer un dossier,\npour stocker vos données.';

  @override
  String get file_name_process_text_field_hint =>
      'Veuillez entrer un nom de fichier, sans .';

  @override
  String get ca_new_process_button =>
      'Veuillez cliquer pour démarrer\nune nouvelle analyse de contexte.';

  @override
  String get ca_unfilled_analysis_title => 'Sans titre';

  @override
  String get ca_dashboard_title => 'Analyses précédentes';

  @override
  String get ca_dashboard_sort_by_title => 'Tri par titre';

  @override
  String get ca_dashboard_sort_by_date => 'Tri par date';
}
