import 'package:flutter/material.dart';

import 'package:journeyers/core/utils/csv/csv_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';

CSVUtils cu = CSVUtils();
PrintUtils pu = PrintUtils();

class GroupProblemSolvingPreviewWidget extends StatefulWidget 
{
  final String pathToStoredData;

  const GroupProblemSolvingPreviewWidget({
    super.key, 
    required this.pathToStoredData
  });

  @override
  State<GroupProblemSolvingPreviewWidget> createState() => _GroupProblemSolvingPreviewWidgetState();
}

class _GroupProblemSolvingPreviewWidgetState extends State<GroupProblemSolvingPreviewWidget> 
{
  bool _isLoading = true;

  
  @override
  void initState() 
  {
    super.initState();
    _fetchingData();
  }

  Future<void> _fetchingData() async
  {
    // to complete
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  


  @override
  Widget build(BuildContext context) 
  {
    return _isLoading
      ?  const Center(child:CircularProgressIndicator())
      :  Column
        (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: 
          [
              Text('To complete')
              
          ],
        );
  }
}