import 'package:flutter/material.dart';

/// A widget with a chain of checkboxes appearing only if the previous checkbox has been checked.
/// The widget can be used to limit on-screen cognitive complexity.

class CascadingCheckboxes extends StatefulWidget {
  /// The label of the first checkbox
  final String firstCheckboxLabel;
  /// The label of the second checkbox
  final String secondCheckboxLabel;
  /// The label of the third checkbox
  final String thirdCheckboxLabel;
  /// The label of the fourth checkbox
  final String forthCheckboxLabel;
  /// The size of the SizedBox encapsulating the checkbox (allows for the text to be close to the checkbox)
  final double sizedBoxesWidth;

  const CascadingCheckboxes({
    super.key,
    this.firstCheckboxLabel = 'First checkbox label',
    this.secondCheckboxLabel = 'Second checkbox label',
    this.thirdCheckboxLabel = 'Third checkbox label',
    this.forthCheckboxLabel = 'Fourth checkbox label',
    this.sizedBoxesWidth = 400,
  });

  @override
  State<CascadingCheckboxes> createState() => _CascadingCheckboxesState();
}

class _CascadingCheckboxesState extends State<CascadingCheckboxes> 
{
  bool _isFirstCheckboxChecked = false;
  bool _isSecondCheckboxChecked = false;
  bool _isThirdCheckboxChecked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [        
        if (!_isFirstCheckboxChecked & !_isSecondCheckboxChecked & !_isThirdCheckboxChecked)
          SizedBox
          (
            width: widget.sizedBoxesWidth,
            child: CheckboxListTile(
              title: Text
                ( 
                  widget.firstCheckboxLabel,
                  textAlign: TextAlign.center,                  
                  style: Theme.of(context).textTheme.headlineSmall,
                  
                ),
              value: _isFirstCheckboxChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isFirstCheckboxChecked = value!;
                  if (!_isFirstCheckboxChecked) {
                    _isSecondCheckboxChecked = false;
                    _isThirdCheckboxChecked = false;
                  }
                });
              },
            ),
          ),
         if (_isFirstCheckboxChecked & !_isSecondCheckboxChecked & !_isThirdCheckboxChecked)
         SizedBox
          (
            width: widget.sizedBoxesWidth,
            child: CheckboxListTile(
              title: Text
              (
                widget.secondCheckboxLabel,
                textAlign: TextAlign.center,                
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              value: _isSecondCheckboxChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isSecondCheckboxChecked = value!;
                  if (!_isSecondCheckboxChecked) {
                    _isThirdCheckboxChecked = false;
                  }
                });
              },
            ),
          ),
        if (_isFirstCheckboxChecked & _isSecondCheckboxChecked & !_isThirdCheckboxChecked)
           SizedBox
          (
            width: widget.sizedBoxesWidth,
            child: CheckboxListTile(
              title: Text
              (
                widget.thirdCheckboxLabel,
                textAlign: TextAlign.center,                
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              value: _isThirdCheckboxChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isThirdCheckboxChecked = value!;
                });
              },
            ),
          ),
          if (_isFirstCheckboxChecked & _isSecondCheckboxChecked & _isThirdCheckboxChecked)
          SizedBox
          (
            width: widget.sizedBoxesWidth,
            child: ListTile(
              title: Text
              (
                widget.forthCheckboxLabel,
                textAlign: TextAlign.center,                
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          )          
      ],
    );
  }
}