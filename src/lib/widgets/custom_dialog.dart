import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';

import 'package:kira_auth/utils/strings.dart';

class CustomDialog extends StatefulWidget {
  final List<Widget> contentWidgets;

  const CustomDialog({Key key, this.contentWidgets}) : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 40, top: 65, right: 40, bottom: 20),
          margin: EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: new Border.all(
                color: KiraColors.kPurpleColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(color: KiraColors.kLightPurpleColor, offset: Offset(5, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.contentWidgets,
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(
                  color: KiraColors.kPurpleColor,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: KiraColors.white,
                radius: 45,
                child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(45)), child: Image.asset(Strings.logoImage)),
              )),
        ),
      ],
    );
  }
}
