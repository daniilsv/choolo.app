import 'package:flutter/material.dart';
import 'package:itis_cards/styles/style.dart';

class FormInputField extends StatelessWidget {
  FormInputField({
    this.width,
    this.height = 40.0,
    this.inputType = TextInputType.text,
    this.initialValue = "",
    this.textColor = StyleColors.primary,
    this.fontSize = 24.0,
    this.textAlign = TextAlign.start,
    this.hint = "",
    this.hintColor = StyleColors.primary,
    this.hintSize = 24.0,
    this.maxLines = 1,
    this.icon,
    this.onSaved,
    this.validator,
  });

  final double height;
  final double width;
  final TextInputType inputType;
  final String initialValue;
  final String hint;
  final Color hintColor;
  final double hintSize;
  final TextAlign textAlign;
  final Color textColor;
  final double fontSize;
  final int maxLines;
  final Icon icon;
  final FormFieldSetter onSaved;
  final FormFieldValidator validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: maxLines > 1 ? (fontSize * maxLines + fontSize) : height,
      width: width ?? MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        keyboardType: inputType,
        initialValue: initialValue ?? "",
        textAlign: textAlign,
        textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.done,
        maxLines: maxLines,
        style: TextStyle(color: textColor, fontSize: fontSize),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint ?? "",
          hintStyle: TextStyle(color: hintColor, fontSize: hintSize),
          icon: icon,
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}
