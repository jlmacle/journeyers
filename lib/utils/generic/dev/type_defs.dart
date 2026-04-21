/// A function that returns a record,
/// with a boolean (true if a String should be sanitized),
/// and with a function to sanitize the string.
typedef StringSanitizerBundle = 
({
  bool shouldStringBeSanitized, 
  dynamic Function(dynamic) sanitizingFunction
}) 
Function(String);

/// A function that returns true if a String should be blocked.
typedef BlacklistingFunction = 
bool Function(String value);

/// An async function with a Set<String> parameter, and a String parameter.
typedef FunctionSetStringAndString = 
Future<void> Function({required String? filePath, required Set<String> updatedKeywords});