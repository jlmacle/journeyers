import 'dart:ui' as ui;

import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';

void printDeviceLocale() {
  final locale = ui.PlatformDispatcher.instance.locale;
  pu.printd('Device locale: ${locale.toString()}');
  pu.printd('Language code: ${locale.languageCode}');
  pu.printd('Country code: ${locale.countryCode}');
}
