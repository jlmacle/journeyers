// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Journeyers';

  @override
  String get appSubTitle =>
      'What story will we leave\nfor our loved ones to tell?';

  @override
  String get lang_fr => 'French';

  @override
  String get lang_en => 'English';
}

/// The translations for English, as used in the United States (`en_US`).
class AppLocalizationsEnUs extends AppLocalizationsEn {
  AppLocalizationsEnUs() : super('en_US');

  @override
  String get appTitle => 'Journeyers';

  @override
  String get appSubTitle =>
      'What story will we leave\nfor our loved ones to tell?';

  @override
  String get lang_fr => 'French';

  @override
  String get lang_en => 'English';
}
