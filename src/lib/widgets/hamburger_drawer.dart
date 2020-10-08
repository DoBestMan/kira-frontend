import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';

class HamburgerDrawer extends StatefulWidget {
  const HamburgerDrawer({
    Key key,
  }) : super(key: key);

  @override
  _HamburgerDrawerState createState() => _HamburgerDrawerState();
}

class _HamburgerDrawerState extends State<HamburgerDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).bottomAppBarColor,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                      child: Image(
                    image: AssetImage(Strings.logoImage),
                    width: 110,
                    height: 110,
                  )),
                ],
              ),
              InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      Strings.appbarText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: KiraColors.kYellowColor, fontSize: 25),
                    ),
                  )),
              InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'About',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  )),
              InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Blog',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  )),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Copyright © 2020 | KIRA',
                    style: TextStyle(
                      color: KiraColors.kYellowColor1,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
