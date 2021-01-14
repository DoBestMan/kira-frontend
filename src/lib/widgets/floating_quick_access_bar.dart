import 'package:kira_auth/utils/responsive.dart';
import 'package:flutter/material.dart';

class FloatingQuickAccessBar extends StatefulWidget {
  const FloatingQuickAccessBar({
    Key key,
    @required this.screenSize,
  }) : super(key: key);

  final Size screenSize;

  @override
  _FloatingQuickAccessBarState createState() => _FloatingQuickAccessBarState();
}

class _FloatingQuickAccessBarState extends State<FloatingQuickAccessBar> {
  List _isHovering = [false, false, false, false, false];
  List<Widget> rowElements = [];
  List<String> items = ['Deposit', 'Token Balances', 'Withdrawal', 'Network', 'Settings'];
  List<IconData> icons = [
    Icons.check,
    Icons.crop_square,
    Icons.attach_money,
    Icons.wifi,
    Icons.settings_input_component
  ];

  List<Widget> generateRowElements() {
    rowElements.clear();
    for (int i = 0; i < items.length; i++) {
      Widget elementTile = InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
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
        child: Text(
          items[i],
          style: TextStyle(
            fontSize: 20,
            color: _isHovering[i]
                ? Theme.of(context).primaryTextTheme.button.decorationColor
                : Theme.of(context).primaryTextTheme.button.color,
          ),
        ),
      );

      Widget spacer = SizedBox(
        height: widget.screenSize.height / 20,
        child: VerticalDivider(
          width: 1,
          color: Colors.purple[400],
          thickness: 1,
        ),
      );

      rowElements.add(elementTile);

      if (i < items.length - 1) {
        rowElements.add(spacer);
      }
    }

    return rowElements;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(
          top: widget.screenSize.height * 0.20,
          left: ResponsiveWidget.isSmallScreen(context)
              ? widget.screenSize.width / 12
              : widget.screenSize.width / 5,
          right: ResponsiveWidget.isSmallScreen(context)
              ? widget.screenSize.width / 12
              : widget.screenSize.width / 5,
        ),
        child: ResponsiveWidget.isSmallScreen(context)
            ? Column(
                children: [
                  ...Iterable<int>.generate(items.length).map(
                    (int pageIndex) => Padding(
                      padding:
                          EdgeInsets.only(top: widget.screenSize.height / 80),
                      child: Card(
                        color: Theme.of(context).cardColor,
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: widget.screenSize.height / 45,
                              bottom: widget.screenSize.height / 45,
                              left: widget.screenSize.width / 20),
                          child: Row(
                            children: [
                              Icon(
                                icons[pageIndex],
                                color: Theme.of(context).iconTheme.color,
                              ),
                              SizedBox(width: widget.screenSize.width / 20),
                              InkWell(
                                splashColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                onTap: () {
                                  switch (pageIndex) {
                                    case 0: // Deposit
                                      Navigator.pushReplacementNamed(
                                          context, '/deposit');
                                      break;
                                    case 1: // Token Balances
                                      Navigator.pushReplacementNamed(
                                          context, '/tokens');
                                      break;
                                    case 2: // Withdrawal
                                      Navigator.pushReplacementNamed(
                                          context, '/withdrawal');
                                      break;
                                    case 3: // Network
                                      Navigator.pushReplacementNamed(
                                          context, '/network');
                                      break;
                                    case 4: // Settings
                                      Navigator.pushReplacementNamed(
                                          context, '/settings');
                                      break;
                                  }
                                },
                                child: Text(
                                  items[pageIndex],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .primaryTextTheme
                                          .button
                                          .color,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: widget.screenSize.height / 100,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: generateRowElements(),
                  ),
                ),
              ),
      ),
    );
  }
}
