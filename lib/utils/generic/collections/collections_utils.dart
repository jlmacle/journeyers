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

}
