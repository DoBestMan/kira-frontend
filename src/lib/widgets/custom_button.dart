import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';

// ignore: must_be_immutable
class CustomButton extends StatefulWidget {
  Key key;
  double fontSize;
  String text;
  double width;
  double height;
  EdgeInsets margin;
  double style; // 0: Border only, 1: Gray background, 2: Gradient background
  VoidCallback onPressed;
  Color backgroundColor;

  CustomButton(
      {this.key,
      this.text,
      this.width,
      this.height,
      this.onPressed,
      this.style = 0,
      this.backgroundColor,
      this.fontSize = 15.0})
      : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: FlatButton(
        onPressed: widget.onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          width: widget.width,
          height: widget.height,
          decoration: widget.style == 2
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      //ADD If you need more
                      Color.fromRGBO(134, 53, 213, 1),
                      Color.fromRGBO(85, 53, 214, 1),
                      Color.fromRGBO(7, 200, 248, 1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10.0))
              : widget.style == 1
                  ? BoxDecoration(
                      color: KiraColors.kGrayColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10.0))
                  : null,
          child: Center(
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: widget.fontSize),
            ),
          ),
        ),
      ),
    );
  }
}
