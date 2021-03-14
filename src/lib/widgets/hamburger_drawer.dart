import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/widgets/export.dart';

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
  StatusService statusService = StatusService();
  final List _isHovering = [false, false, false, false, false, false, false, false, false, false];

  String networkId = Strings.noAvailableNetworks;
  List<String> networkIds = [
    Strings.noAvailableNetworks
  ];

  @override
  void initState() {
    super.initState();
    getNodeStatus();
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        if (statusService.nodeInfo.network.isNotEmpty) {
          networkIds.clear();
          networkIds.add(statusService.nodeInfo.network);
          networkId = statusService.nodeInfo.network;
        }
      });
    }
  }

  List<Widget> navItems() {
    List<Widget> items = [];

    for (int i = 0; i < 6; i++) {
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
              case 4: // Proposals
                Navigator.pushReplacementNamed(context, '/proposals');
                break;
              case 5: // Settings
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

  showAvailableNetworks(BuildContext context) {
    // set up the buttons
    Widget closeButton = TextButton(
      child: Text(
        Strings.close,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          contentWidgets: [
            Text(
              Strings.availableNetworks,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: KiraColors.kPurpleColor, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              Strings.networkDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 15,
            ),
            ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                  dropdownColor: KiraColors.white,
                  value: networkId,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 32,
                  underline: SizedBox(),
                  onChanged: (String netId) {
                    setState(() {
                      networkId = netId;
                    });
                  },
                  items: networkIds.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(height: 25, alignment: Alignment.topCenter, child: Text(value, style: TextStyle(color: KiraColors.kLightPurpleColor, fontSize: 18, fontWeight: FontWeight.w400))),
                    );
                  }).toList()),
            ),
            SizedBox(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
              closeButton
            ]),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var networkStatusColor = widget.isNetworkHealthy == true ? KiraColors.green3 : KiraColors.orange3;

    return Drawer(
      elevation: 1,
      child: Container(
        color: Color.fromARGB(255, 60, 20, 100),
        padding: const EdgeInsets.all(16.0),
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
                style: TextStyle(color: KiraColors.white, fontSize: 24),
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
                    // onTap: widget.isNetworkHealthy == null ? () {} : null,
                    onTap: () {
                      showAvailableNetworks(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          networkId,
                          style: TextStyle(fontFamily: 'Mulish', color: Colors.white.withOpacity(0.5), fontSize: 15, letterSpacing: 1),
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
                                  size: 15.0,
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
                          color: KiraColors.kGrayColor,
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
