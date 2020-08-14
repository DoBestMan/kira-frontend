import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomButton extends StatefulWidget {
  CustomButton(
      {this.key, this.text, this.height, this.onPressed, this.backgroundColor})
      : super(key: key);
  Key key;
  String text;
  double height;
  VoidCallback onPressed;
  Color backgroundColor;

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
              style: TextStyle(color: Colors.white, fontSize: 20.0)),
          shape: new RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.height / 4))),
          color: widget.backgroundColor,
          textColor: Colors.black87,
          onPressed: widget.onPressed),
    );
  }
}
