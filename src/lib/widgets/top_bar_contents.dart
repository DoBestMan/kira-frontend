import 'dart:ui';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/widgets/export.dart';

class TopBarContents extends StatefulWidget {
  final double opacity;
  final bool _loggedIn;
  final bool _isNetworkHealthy;

  TopBarContents(this.opacity, this._loggedIn, this._isNetworkHealthy);

  @override
  _TopBarContentsState createState() => _TopBarContentsState();
}

class _TopBarContentsState extends State<TopBarContents> {
  StatusService statusService = StatusService();
  final List _isHovering = [false, false, false, false, false, false, false, false, false, false];

  bool _isProcessing = false;

  // String networkId = Strings.noAvailableNetworks;
  List<String> networkIds = [Strings.noAvailableNetworks];

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
          // networkId = statusService.nodeInfo.network;
        }
      });
    }
  }

  List<Widget> navItems() {
    List<Widget> items = [];

    for (int i = 0; i < 6; i++) {
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
              case 0: // Acount
                Navigator.pushReplacementNamed(context, '/account');
                break;
              case 1: // Deposit
                Navigator.pushReplacementNamed(context, '/deposit');
                break;
              case 2: // Withdrawal
                Navigator.pushReplacementNamed(context, '/withdraw');
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

  showAvailableNetworks(BuildContext context) {
    var networkId = BlocProvider.of<NetworkBloc>(context).state.networkId;
    networkId = networkId == null ? Strings.noAvailableNetworks : networkId;

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
                    BlocProvider.of<NetworkBloc>(context).add(SetNetworkId(networkId));
                  },
                  items: networkIds.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                          height: 25,
                          alignment: Alignment.topCenter,
                          child: Text(value,
                              style: TextStyle(
                                  color: KiraColors.kLightPurpleColor, fontSize: 18, fontWeight: FontWeight.w400))),
                    );
                  }).toList()),
            ),
            SizedBox(height: 22),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[closeButton]),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var networkStatusColor = widget._isNetworkHealthy == true ? KiraColors.green3 : KiraColors.orange3;
    var networkId = BlocProvider.of<NetworkBloc>(context).state.networkId;
    networkId = networkId == null ? Strings.noAvailableNetworks : networkId;

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
                  Strings.kiraNetwork,
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
            widget._loggedIn == true
                ? Expanded(
                    child: Center(
                        child: Wrap(
                      children: navItems(),
                    )),
                  )
                : Expanded(child: SizedBox(width: 500)),
            SizedBox(
              width: screenSize.width / 50,
            ),
            InkWell(
              // onTap: widget._isNetworkHealthy == null ? () {} : null,
              onTap: () {
                showAvailableNetworks(context);
              },
              child: Row(
                children: [
                  Text(
                    networkId,
                    style: TextStyle(
                        fontFamily: 'Mulish', color: Colors.white.withOpacity(0.5), fontSize: 15, letterSpacing: 1),
                  ),
                  SizedBox(width: 12),
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
                  if (widget._loggedIn == true)
                    ElevatedButton(
                      // color: KiraColors.transparent,
                      // hoverColor: KiraColors.purple1,
                      // highlightColor: KiraColors.purple2,
                      onPressed: () {
                        if (widget._loggedIn) {
                          removeCachedPassword();
                          Navigator.pushReplacementNamed(context, '/');
                        } else {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(5), side: BorderSide(color: KiraColors.buttonBorder)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                        child: _isProcessing
                            ? CircularProgressIndicator()
                            : Text(
                                widget._loggedIn == true ? Strings.logout : Strings.login,
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
