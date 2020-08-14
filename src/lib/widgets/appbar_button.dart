import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';

// ignore: must_be_immutable
class AppBarButton extends StatefulWidget {
  AppBarButton(
      {this.key,
      this.text,
      this.width,
      this.height,
      this.onPressed,
      this.backgroundColor})
      : super(key: key);

  Key key;
  String text;
  double width;
  double height;
  VoidCallback onPressed;
  Color backgroundColor;

  @override
  _AppBarButtonState createState() => _AppBarButtonState();
}

class _AppBarButtonState extends State<AppBarButton> {
  @override
  Widget build(BuildContext context) {
    // return RaisedButton(
    //     onPressed: () {},
    //     textColor: Colors.white,
    //     color: kPrimaryColor,
    //     padding: const EdgeInsets.all(10.0),
    //     child: Container(
    //         padding:
    //             const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    //         child: const Text('  Log In  ')));
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          print(widget.text);
          widget.onPressed();
        },
        child: Container(
          margin: EdgeInsets.only(left: 0),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [KiraColors.purple1, KiraColors.purple2],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 2, color: Colors.white12),
              boxShadow: [
                BoxShadow(
                    color: KiraColors.purple3.withOpacity(0.3),
                    offset: Offset(0, 8), //Shadow starts at x=0, y=8
                    blurRadius: 8)
              ]),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Text(
                widget.text,
                style: TextStyle(
                    color: KiraColors.white1, fontSize: 18, letterSpacing: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
