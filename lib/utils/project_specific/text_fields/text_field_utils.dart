import "package:journeyers/utils/generic/dev/type_defs.dart";
import "package:journeyers/utils/generic/text_fields/text_field_utils.dart";  

/// {@category Utils - Project-specific}
/// A project-specific utility class related to text fields string sanitization.
class TextFieldStringSanitizerBundlesErrorsMappings
 { 
  // ─── MAPS WITH STRING SANITIZER BUNDLES AS KEYS, AND ERROR MESSAGES AS VALUES ───────────────────────────────────────
  /// A map with String sanitizer bundles as keys, and error messages as values,
  /// for the context analysis text fields.
  static const Map<StringSanitizerBundle, String> stringSanitizerBundlesErrorsMappingForCA = 
  {
    TextFieldUtils.containsAStraightQuote :TextFieldUtils.errorContainsAStraightQuote,
  };  

  /// A map with String sanitizer bundles as keys, and error messages as values,
  /// for the file names used on mobile platforms.
  static const Map<StringSanitizerBundle, String> stringSanitizerBundlesErrorsMappingForFileNames = 
  {
    TextFieldUtils.containsADot : TextFieldUtils.errorContainsADot
  }; 


  // ─── MAPS WITH BLACKLISTING FUNCTIONS AS KEYS, AND ERROR MESSAGES AS VALUES ───────────────────────────────────────
  /// A map with (CSV files) blacklisting functions as keys, and error messages as values.
  static const Map<BlacklistingFunction, String> blacklistingFunctionsErrorsMappingForCSVFileNames = 
  {
    TextFieldUtils.fileNameAlreadyUsedCSV : TextFieldUtils.errorFileNameAlreadyUsed
  }; 

   /// A map with (TXT files) blacklisting functions as keys, and error messages as values.
  static const Map<BlacklistingFunction, String> blacklistingFunctionsErrorsMappingForTXTFileNames = 
  {
    TextFieldUtils.fileNameAlreadyUsedTXT : TextFieldUtils.errorFileNameAlreadyUsed
  }; 
 
  
}
