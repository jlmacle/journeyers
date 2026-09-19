import "package:intl/intl.dart";

/// {@category Utils - Generic}
/// A generic utility class related to date formats.
class DateUtils 
{
  /// Date format for "MMMM dd, yyyy".
  static const dateFormatMMMMddyyyy = "MMMM dd, yyyy";
  
  /// French date format used.
  /// French: "17 septembre 2026 08:29" -> d MMMM yyyy HH:mm (24h clock)
  static final frFormat = DateFormat("d MMMM yyyy HH:mm", "fr_FR");

  /// US English date format used.
  /// US English: "September 5, 2026 1:54 AM" -> MMMM d, yyyy h:mm a (12h clock)
  static final enFormat = DateFormat("MMMM d, yyyy h:mm a", "en_US");

  /// Replaces all non-alphanumeric characters (Unicode), non ',' and non ':' 
  /// with a single space.
  static String sanitizeDate(String? input) {

    if (input == null) return "";

    // \p{L} matches any letter in any language (A-Z, a-z, é, à, etc.)
    // \p{N} matches any numeric digit (0-9)
    final regex = RegExp(r"[^\p{L}\p{N},:]", unicode: true);  
    return input.replaceAll(regex, " ");
  }
}

