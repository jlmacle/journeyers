

/// Method used to sort list keys  (format: sequence of a->z + digit, e.g. abc0).
/// The method assumes that all keys have the same length.
String getBiggestKey(List<String> keysList)
{
  return (keysList..sort())[keysList.length - 1];
}