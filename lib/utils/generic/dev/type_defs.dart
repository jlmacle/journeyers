/// A function that returns a record,
/// with a boolean (true if a String should be sanitized),
/// and with a function to sanitize the string.
typedef StringSanitizerBundle = 
({
  bool shouldStringBeSanitized, 
  dynamic Function(dynamic) sanitizingFunction
}) 
Function(String);

/// An async function that returns a true if a String should be blocked,
typedef BlacklistingFunction = 
bool Function(String value);