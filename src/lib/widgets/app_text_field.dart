import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kira_auth/utils/colors.dart';

/// TextField button
class TextFieldButton extends StatelessWidget {
  final IconData icon;
  final Function onPressed;

  TextFieldButton({@required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 48,
        width: 48,
        child: FlatButton(
          padding: EdgeInsets.all(14.0),
          onPressed: () {
            onPressed();
          },
          child: Icon(icon, size: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200.0)),
        ));
  }
}

/// A widget for our custom textfields
class AppTextField extends StatefulWidget {
  final TextAlign textAlign;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Color cursorColor;
  final Brightness keyboardAppearance;
  final List<TextInputFormatter> inputFormatters;
  final TextInputAction textInputAction;
  final int minLines;
  final int maxLines;
  final bool autocorrect;
  final String hintText;
  final TextFieldButton prefixButton;
  final TextFieldButton suffixButton;
  final bool fadePrefixOnCondition;
  final bool prefixShowFirstCondition;
  final bool fadeSuffixOnCondition;
  final bool suffixShowFirstCondition;
  final EdgeInsetsGeometry padding;
  final Widget overrideTextFieldWidget;
  final int buttonFadeDurationMs;
  final TextInputType keyboardType;
  final Function onSubmitted;
  final Function onChanged;
  final Function onHalfClicked;
  final Function onMaxClicked;
  final double topMargin;
  final double leftMargin;
  final double rightMargin;
  final TextStyle style;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final bool showMax;

  AppTextField(
      {this.focusNode,
      this.controller,
      this.cursorColor,
      this.inputFormatters,
      this.textInputAction,
      this.hintText,
      this.prefixButton,
      this.suffixButton,
      this.fadePrefixOnCondition,
      this.prefixShowFirstCondition,
      this.fadeSuffixOnCondition,
      this.suffixShowFirstCondition,
      this.overrideTextFieldWidget,
      this.keyboardType,
      this.onSubmitted,
      this.onChanged,
      this.onHalfClicked,
      this.onMaxClicked,
      this.style,
      this.enabled = true,
      this.leftMargin,
      this.rightMargin,
      this.obscureText = false,
      this.textAlign = TextAlign.center,
      this.keyboardAppearance = Brightness.dark,
      this.autocorrect = true,
      this.minLines = 1,
      this.maxLines = 1,
      this.padding = EdgeInsets.zero,
      this.buttonFadeDurationMs = 100,
      this.topMargin = 0,
      this.readOnly = false,
      this.autofocus = false,
      this.showMax = false});

  _AppTextFieldState createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        textAlign: widget.textAlign,
        keyboardAppearance: widget.keyboardAppearance,
        autocorrect: widget.autocorrect,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        focusNode: widget.focusNode,
        controller: widget.controller,
        cursorColor: widget.cursorColor,
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        autofocus: widget.autofocus,
        onSubmitted: widget.onSubmitted != null
            ? widget.onSubmitted
            : (text) {
                if (widget.textInputAction == TextInputAction.done) {
                  FocusScope.of(context).unfocus();
                }
              },
        onChanged: widget.onChanged,
        // Style
        style: widget.style,
        // Input decoration
        decoration: InputDecoration(
          border: InputBorder.none,
          // Hint
          hintText: widget.hintText == null ? "" : widget.hintText,
          hintStyle: TextStyle(
            fontSize: 17.0,
            color: KiraColors.kGrayColor,
            fontWeight: FontWeight.w100,
            fontFamily: 'NunitoSans',
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          labelStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: KiraColors.kGrayColor.withOpacity(0.3), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: KiraColors.kPurpleColor, width: 2),
          ),
        ));
  }
}
