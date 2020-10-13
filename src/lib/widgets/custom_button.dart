import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomButton extends StatefulWidget {
  Key key;
  double fontSize;
  String text;
  double height;
  VoidCallback onPressed;
  Color backgroundColor;

  CustomButton(
      {this.key,
      this.text,
      this.height,
      this.onPressed,
      this.backgroundColor,
      this.fontSize = 20.0})
      : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      constraints: BoxConstraints.expand(height: widget.height),
      child: new RaisedButton(
          child: new Text(widget.text,
              style: TextStyle(color: Colors.white, fontSize: widget.fontSize)),
          shape: new RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.height / 4))),
          color: widget.backgroundColor,
          textColor: Colors.black87,
          onPressed: widget.onPressed),
    );
  }
}
