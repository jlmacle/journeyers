/// Method used to replace line returns with a space, and returning null if the text is null.
String? lineReturnToSpace(String? text)
{
  if (text == null) return null;
  return text.replaceAll("\n", " ");
}