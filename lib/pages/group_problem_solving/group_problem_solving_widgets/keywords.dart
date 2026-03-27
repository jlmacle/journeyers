import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';

class Keywords extends StatefulWidget {
  /// A callback function called to update the keywords describing a session.
  final ValueChanged<List<String>> keywordsUpdatedCallbackFunction;

  const Keywords
  ({
    super.key,
    required this.keywordsUpdatedCallbackFunction
  });


  @override
  State<Keywords> createState() => _KeywordsState();
}

class _KeywordsState extends State<Keywords> 
{
   final List<String> _keywords = [];
  final TextEditingController _keywordsController = TextEditingController();
    
  // Method used to add keywords to the _keywords list
  void addKeyword(String value, [StateSetter? localSetState]) {
  var trimmedValue = value.trim();
  if (trimmedValue.isNotEmpty && !_keywords.contains(trimmedValue)) {
    // Updates the underlying data
    setState(() {
      _keywords.add(trimmedValue);
      _keywordsController.clear();
    });
    
    // Redraws the Dialog/Overlay
    if (localSetState != null) {
      localSetState(() {});
    }
    
    widget.keywordsUpdatedCallbackFunction(_keywords);
  }
}

  @override
  void dispose()
  {
    _keywordsController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showKeywordsOverlay(context),
      child: Container(        
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.style_rounded),
            ),
            Center(
              child: Text("Keywords", style: problemSolvingKeywordsTitle),
            )
          ],
        ),
      ),
    );
  }

  void _showKeywordsOverlay(BuildContext context) {
    const String title = "Please enter keywords\nto describe the analysis.";

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close Preview",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true, 
            automaticallyImplyLeading : false,
            title: 
            const Padding
            (
              padding: EdgeInsets.all(16.0), 
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 20,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: problemSolvingKeywordsMessage,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                color: appBarWhite,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: SafeArea(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setLocalState) {
                return 
                Column
    (
      children: 
      [                     
        Padding
        (
          padding: const EdgeInsets.only(left:20, right:20, top:10, bottom:0),
          child: TextField
          (
            controller: _keywordsController,
            decoration: const InputDecoration
            (
              hint: Center
              (
                child: 
                Text(textAlign: TextAlign.center, 'Please enter the keywords here. \n(+ Enter key).', style: analysisTextFieldHintStyle)
              )
            ),
            textAlign: TextAlign.center,
            style: analysisTextFieldStyle,
            onSubmitted: (value) => addKeyword(value, setLocalState),
          ),
        ),
        // Display of the keywords
        Center
        (
          child: Padding
          (
            padding: const EdgeInsets.only(bottom: 0),
            child: Wrap
            (
              spacing: 8.0,
              runSpacing: 4.0,
              children: 
              [
                ..._keywords.map
                (
                  (tag) => InputChip
                          (
                            label: Text(tag),
                            onDeleted: () 
                            {
                              setState( () {_keywords.remove(tag);});
                              setLocalState(() {});
                              widget.keywordsUpdatedCallbackFunction(_keywords);
                            }, 
                            deleteIconColor: appBarWhite,
                          )
                )
              ],
            ),
          ),
        ),
      ],
    ); 
              },
            ),
          ),
        );
      },
    );
  }
}