/// Method used to replace line returns with a space
String? lineReturnToSpace(String? text)
{
  if (text == null) return null;
  return text.replaceAll("\n", " ");
}