import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kira_auth/widgets/appbar_button.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/cache.dart';

class CustomAppBar extends StatefulWidget {
  @override
  _CustomAppBarState createState() {
    return new _CustomAppBarState();
  }
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool authenticated;

  @override
  void initState() {
    super.initState();

    checkPasswordExists().then((success) {
      setState(() {
        authenticated = success;
      });
    });
  }

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Flexible(
            child: Container(
          width: 100,
          height: 100,
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          child: FlatButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              child: Image(image: AssetImage(Strings.logoImage))),
        )),

        Expanded(
            child: SizedBox(
                width: 50,
                child: Text(Strings.appbarText,
                    style: GoogleFonts.sourceSansPro(
                        textStyle: TextStyle(
                      fontSize: 40,
                      color: KiraColors.kYellowColor,
                    ))))),

        authenticated == false
            ? Theme(
                data:
                    Theme.of(context).copyWith(canvasColor: Colors.transparent),
                child: Row(
                  children: <Widget>[
                    AppBarButton(
                        key: Key('account'),
                        text: Strings.login,
                        width: 120,
                        height: 40,
                        backgroundColor: Colors.blue,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/');
                        }),
                    AppBarButton(
                        key: Key('signup'),
                        text: Strings.createNewAccount,
                        width: 200,
                        height: 40,
                        backgroundColor: Colors.blue,
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/create-account');
                        }),
                  ],
                ))
            : Theme(
                data:
                    Theme.of(context).copyWith(canvasColor: Colors.transparent),
                child: Row(
                  children: <Widget>[
                    AppBarButton(
                        key: Key('settings'),
                        text: Strings.settings,
                        width: 120,
                        height: 40,
                        backgroundColor: Colors.blue,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/settings');
                        }),
                  ],
                ))

        //Menu item can be added here
      ],
    );
  }
}
