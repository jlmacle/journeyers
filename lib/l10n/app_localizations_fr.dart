// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
/// {@category L10n}
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Compagnons';

  @override
  String get appSubTitle => 'Quelle histoire laisserons-nous à nos proches ?';

  @override
  String get lang_fr => 'Français';

  @override
  String get lang_en => 'Anglais';
}

/// The translations for French, as used in France (`fr_FR`).
/// {@category L10n}
class AppLocalizationsFrFr extends AppLocalizationsFr {
  AppLocalizationsFrFr() : super('fr_FR');

  @override
  String get appTitle => 'Compagnons';

  @override
  String get appSubTitle => 'Quelle histoire laisserons-nous à nos proches ?';

  @override
  String get lang_fr => 'Français';

  @override
  String get lang_en => 'Anglais';
}
