import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';

class HamburgerDrawer extends StatefulWidget {
  final bool isNetworkHealthy;

  HamburgerDrawer({
    Key key,
    this.isNetworkHealthy,
  }) : super(key: key);

  @override
  _HamburgerDrawerState createState() => _HamburgerDrawerState();
}

class _HamburgerDrawerState extends State<HamburgerDrawer> {
  final List _isHovering = [false, false, false, false, false, false, false, false, false];

  List<Widget> navItems() {
    List<Widget> items = [];

    for (int i = 0; i < 5; i++) {
      items.add(
        InkWell(
          onHover: (value) {
            setState(() {
              value ? _isHovering[i] = true : _isHovering[i] = false;
            });
          },
          onTap: () {
            switch (i) {
              case 0: // Deposit
                Navigator.pushReplacementNamed(context, '/deposit');
                break;
              case 1: // Token Balances
                Navigator.pushReplacementNamed(context, '/tokens');
                break;
              case 2: // Withdrawal
                Navigator.pushReplacementNamed(context, '/withdrawal');
                break;
              case 3: // Network
                Navigator.pushReplacementNamed(context, '/network');
                break;
              case 4: // Settings
                Navigator.pushReplacementNamed(context, '/settings');
                break;
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Strings.navItemTitles[i],
                style: TextStyle(
                  fontSize: 18,
                  color: _isHovering[i] ? KiraColors.white : KiraColors.kGrayColor,
                ),
              ),
              SizedBox(height: 5),
              Visibility(
                maintainAnimation: true,
                maintainState: true,
                maintainSize: true,
                visible: _isHovering[i],
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 3,
                  width: 30,
                  color: KiraColors.kYellowColor,
                ),
              ),
              SizedBox(height: 18),
            ],
          ),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    var networkStatusColor = widget.isNetworkHealthy == true ? KiraColors.green3 : KiraColors.orange3;

    return Drawer(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
                child: Image(
              image: AssetImage(Strings.logoImage),
              width: 90,
              height: 90,
            )),
            Container(
              padding: const EdgeInsets.all(15.0),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                Strings.kiraNetwork,
                textAlign: TextAlign.center,
                style: TextStyle(color: KiraColors.kYellowColor, fontSize: 24),
              ),
            ),
            ConstrainedBox(constraints: BoxConstraints(minHeight: 30)),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: navItems(),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: widget.isNetworkHealthy == null ? () {} : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Strings.networkStatus,
                          style: TextStyle(
                              fontFamily: 'Mulish',
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 15,
                              letterSpacing: 1),
                        ),
                        SizedBox(width: 10),
                        Container(
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              border: new Border.all(
                                color: networkStatusColor.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              child: Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.circle,
                                  size: 12.0,
                                  color: networkStatusColor,
                                ),
                              ),
                            )),
                        SizedBox(
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        Strings.copyRight,
                        style: TextStyle(
                          color: KiraColors.kYellowColor1,
                          fontSize: 14,
                        ),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
