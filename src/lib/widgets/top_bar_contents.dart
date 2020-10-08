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
  final List _isHovering = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return PreferredSize(
      preferredSize: Size(screenSize.width, 1000),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        color: Theme.of(context).bottomAppBarColor.withOpacity(widget.opacity),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  InkWell(
                      onTap: () => Navigator.pushReplacementNamed(context, '/'),
                      child: Image(
                          image: AssetImage(Strings.logoImage),
                          width: 80,
                          height: 80)),
                  SizedBox(width: 20),
                  Text(
                    Strings.appbarText,
                    style: TextStyle(
                      color: KiraColors.orange3,
                      fontSize: 30,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // InkWell(
                    //   onHover: (value) {
                    //     setState(() {
                    //       value
                    //           ? _isHovering[0] = true
                    //           : _isHovering[0] = false;
                    //     });
                    //   },
                    //   onTap: () {},
                    //   child: Column(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Text(
                    //         'About',
                    //         style: TextStyle(
                    //           fontSize: 18,
                    //           color: _isHovering[0]
                    //               ? Colors.blue[200]
                    //               : Colors.white,
                    //         ),
                    //       ),
                    //       SizedBox(height: 5),
                    //       Visibility(
                    //         maintainAnimation: true,
                    //         maintainState: true,
                    //         maintainSize: true,
                    //         visible: _isHovering[0],
                    //         child: Container(
                    //           height: 2,
                    //           width: 20,
                    //           color: Colors.white,
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(
                width: screenSize.width / 50,
              ),
              InkWell(
                onTap: widget._isNetworkHealthy == null ? () {} : null,
                child: Row(
                  children: [
                    Text(
                      "NETWORK STATUS : ",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    InkWell(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.circle,
                          size: 15.0,
                          color: widget._isNetworkHealthy == true
                              ? KiraColors.green3
                              : KiraColors.orange3,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
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
                    SizedBox(width: 15),
                    RaisedButton(
                      color: KiraColors.kLightPurpleColor,
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
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey[50])),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 6.0),
                        child: _isProcessing
                            ? CircularProgressIndicator()
                            : Text(
                                widget._loggedIn == true ? 'Log out' : 'Log in',
                                style: TextStyle(
                                  fontSize: 17,
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
      ),
    );
  }
}
