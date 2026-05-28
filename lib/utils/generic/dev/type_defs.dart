import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';

/// {@category Utils - Generic}
/// A function that returns a record,
/// with a boolean (true if a string should be sanitized),
/// and with a function to sanitize the string.
typedef StringSanitizerBundle = 
({
  bool shouldStringBeSanitized, 
  dynamic Function(dynamic) sanitizingFunction
}) 
Function(String);

/// {@category Utils - Generic}
/// A function that returns true if a string should be blocked.
typedef BlacklistingFunction = 
bool Function(String value);

/// {@category Utils - Generic}
/// An async function with a Set\<String\> parameter, and a String parameter.
typedef FunctionSetStringAndString = 
Future<void> Function({required String? filePath, required Set<String> updatedKeywords});

/// {@category Utils - Generic}
/// An async function without parameters, and returning Future\<void\>.
typedef FutureVoidCallback = 
Future<void> Function();

/// {@category Utils - Generic}
/// A function with a DTOCAForm parameter, and 2 String parameters, and returning void.
typedef FunctionDTOCAFormAnd2Strings = 
void Function({required DTOCAForm dtoForEdition, required String editedFileNameWithoutExtension, required String editedTitle});
