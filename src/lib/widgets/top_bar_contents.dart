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

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var networkStatusColor = widget._isNetworkHealthy == true ? KiraColors.green3 : KiraColors.orange3;

    return PreferredSize(
      preferredSize: Size(screenSize.width, 1000),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: EdgeInsets.all(30),
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
                      "Network status ",
                      style: TextStyle(
                          fontFamily: 'Mulish', color: Colors.white.withOpacity(0.5), fontSize: 15, letterSpacing: 1),
                    ),
                    SizedBox(width: 15),
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
      ),
    );
  }
}
