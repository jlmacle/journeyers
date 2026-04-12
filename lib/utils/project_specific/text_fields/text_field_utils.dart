import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart' as tfu_gen;  

/// {@category Utils - Project-specific}
/// A project-specific utility class related to text fields.
class TextFieldUtils
 { 
  //*********************  MAP WITH STRING SANITIZER BUNDLES AS KEYS, AND ERROR MESSAGES AS VALUES *********************//
  
  /// A map with String sanitizer bundles as keys, and error messages as values,
  /// for the context analysis text fields.
  static const Map<StringSanitizerBundle, String> stringSanitizerBundlesErrorsMapForCA = 
  {
    tfu_gen.TextFieldUtils.containsAStraightQuote : tfu_gen.TextFieldUtils.containsAStraightQuoteError,
  };  

  /// A map with String sanitizer bundles as keys, and error messages as values,
  /// for the file names used on mobile platforms.
  static const Map<StringSanitizerBundle, String> stringSanitizerBundlesErrorsMapForFileNames = 
  {
    tfu_gen.TextFieldUtils.containsADot : tfu_gen.TextFieldUtils.containsADotError
  }; 
}
