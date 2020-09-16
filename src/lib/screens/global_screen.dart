import 'package:flutter/material.dart';
import 'package:kira_auth/utils/cache.dart';
import 'package:kira_auth/widgets/header_wrapper.dart';

class GlobalScreen extends StatefulWidget {
  @override
  _GlobalScreenState createState() {
    return new _GlobalScreenState();
  }
}

class _GlobalScreenState extends State<GlobalScreen> {
  @override
  void initState() {
    super.initState();

    checkPasswordExpired().then((success) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/account');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: HeaderWrapper(
            childWidget: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[],
      ),
    )));
  }
}
