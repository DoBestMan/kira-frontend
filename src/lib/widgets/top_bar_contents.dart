import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/cache.dart';

class TopBarContents extends StatefulWidget {
  final double opacity;
  final bool _loggedIn;
  final bool _isNetworkHealthy;

  TopBarContents(this.opacity, this._loggedIn, this._isNetworkHealthy);

  @override
  _TopBarContentsState createState() => _TopBarContentsState();
}

class _TopBarContentsState extends State<TopBarContents> {
  final List _isHovering = [false, false, false, false, false, false, false, false];

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> navItems() {
    List<Widget> items = [];

    for (int i = 0; i < 4; i++) {
      items.add(Container(
        margin: EdgeInsets.only(left: 30, right: 30, top: 10),
        child: InkWell(
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
              case 3: // Settings
                Navigator.pushReplacementNamed(context, '/settings');
                break;
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                Strings.navItemTitles[i],
                style: TextStyle(
                  fontSize: 15,
                  color: _isHovering[i] ? KiraColors.kYellowColor : KiraColors.kGrayColor,
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
              )
            ],
          ),
        ),
      ));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var networkStatusColor = widget._isNetworkHealthy == true ? KiraColors.green3 : KiraColors.orange3;

    return PreferredSize(
      preferredSize: Size(screenSize.width, 1000),
      child: Container(
        height: 120,
        alignment: AlignmentDirectional.center,
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                InkWell(
                    onTap: () => Navigator.pushReplacementNamed(context, '/'),
                    child: Image(image: AssetImage(Strings.logoImage), width: 70, height: 70)),
                SizedBox(width: 5),
                Text(
                  Strings.appbarText,
                  style: TextStyle(
                    color: KiraColors.white,
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                  child: Wrap(
                children: navItems(),
              )),
            ),
            SizedBox(
              width: screenSize.width / 50,
            ),
            InkWell(
              onTap: widget._isNetworkHealthy == null ? () {} : null,
              child: Row(
                children: [
                  Text(
                    "Network status",
                    style: TextStyle(
                        fontFamily: 'Mulish', color: Colors.white.withOpacity(0.5), fontSize: 15, letterSpacing: 1),
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
            InkWell(
              onHover: (value) {
                setState(() {
                  value ? _isHovering[3] = true : _isHovering[3] = false;
                });
              },
              onTap: widget._loggedIn == false ? () {} : null,
              child: Row(
                children: [
                  SizedBox(width: 35),
                  RaisedButton(
                    color: KiraColors.transparent,
                    hoverColor: KiraColors.purple1,
                    highlightColor: KiraColors.purple2,
                    onPressed: () {
                      if (widget._loggedIn) {
                        removeCachedPassword();
                        Navigator.pushReplacementNamed(context, '/');
                      } else {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), side: BorderSide(color: KiraColors.buttonBorder)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                      child: _isProcessing
                          ? CircularProgressIndicator()
                          : Text(
                              widget._loggedIn == true ? 'Log Out' : 'Log In',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
