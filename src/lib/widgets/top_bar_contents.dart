import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';

class TopBarContents extends StatefulWidget {
  final double opacity;
  final bool networkStatus;

  TopBarContents(this.opacity, this.networkStatus);

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
  bool _loggedIn = true;

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
          padding: EdgeInsets.all(20),
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
                      color: KiraColors.kYellowColor,
                      fontSize: 24,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
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
                onTap: widget.networkStatus == null ? () {} : null,
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
                          color: widget.networkStatus == true
                              ? KiraColors.green3
                              : KiraColors.orange3,
                        ),
                      ),
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
                onTap: _loggedIn == null ? () {} : null,
                child: _loggedIn == null
                    ? Text(
                        'Log in',
                        style: TextStyle(
                          color: _isHovering[3] ? Colors.white : Colors.white70,
                        ),
                      )
                    : Row(
                        children: [
                          SizedBox(width: 10),
                          FlatButton(
                            color: Colors.purple,
                            hoverColor: Colors.purple[700],
                            highlightColor: Colors.purple[800],
                            onPressed: () {},
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 8.0,
                                bottom: 8.0,
                              ),
                              child: _isProcessing
                                  ? CircularProgressIndicator()
                                  : Text(
                                      'Log out',
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
