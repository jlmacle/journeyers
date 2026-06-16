/// {@category Utils - Generic}
/// A generic utility class related to collections of items.
class CollectionsUtils 
{
  /// Method used to test that two lists have identical sets of elements.
  bool areListsEqualSets(List list1, List list2) 
  {
    final set1 = Set.from(list1);
    final set2 = Set.from(list2);
    return set1.difference(set2).isEmpty && set2.difference(set1).isEmpty;
  }

  /// Method used to test that two lists have identical elements when sorted.
  bool areListsOfEqualSortedContent(List list1, List list2)
  {
    if (list1.length != list2.length) {return false;}
    else 
    {
      for (var index = 0; index < list1.length; index++)
      {
        if ( (list1..sort())[index] != (list2..sort())[index] ) return false;
      }
    }
    return true;
  }

}
