// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/widgets/custom_button.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/styles.dart';
import 'package:kira_auth/models/account_model.dart';

class LoginWithKeyfileScreen extends StatefulWidget {
  @override
  _LoginWithKeyfileScreenState createState() => _LoginWithKeyfileScreenState();
}

class _LoginWithKeyfileScreenState extends State<LoginWithKeyfileScreen> {
  AccountData accountData;
  String fileName;
  String accountDataString;

  @override
  void initState() {
    super.initState();
    fileName = "";
  }

  void _openFileExplorer() async {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = false;
    uploadInput.draggable = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      final file = files[0];
      final reader = new html.FileReader();

      setState(() {
        fileName = file.name;
      });

      reader.onLoadEnd.listen((e) {
        _handleResult(reader.result);
      });

      reader.readAsText(file);
      // reader.readAsDataUrl(file);
    });
  }

  void _handleResult(Object result) {
    setState(() {
      accountDataString = result.toString();
      accountData = AccountData.fromString(accountDataString);
    });
    print(accountDataString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AppbarWrapper(
            childWidget: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          addHeaderText(),
          // addDescription(),
          addKeyFileInfo(),
          addImportButton(),
          addLoginButton(),
          addGoBackButton(),
        ],
      ),
    )));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Text(
          Strings.loginWithKeyFile,
          textAlign: TextAlign.center,
          style: TextStyle(color: KiraColors.kPrimaryColor, fontSize: 30),
        ));
  }

  Widget addDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.loginWithKeyfileDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: KiraColors.kYellowColor, fontSize: 18),
          ))
        ]));
  }

  Widget addKeyFileInfo() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(child: null),
                Text(Strings.keyfile + ": " + fileName,
                    style: TextStyle(
                        color: KiraColors.kYellowColor, fontSize: 20)),
              ],
            ),
          ],
        ));
  }

  Widget addImportButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.2 : 0.08),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('export'),
          text: Strings.import,
          height: 30.0,
          fontSize: 15,
          onPressed: () {
            _openFileExplorer();
          },
          backgroundColor: KiraColors.green2,
        ));
  }

  Widget addLoginButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('log_in'),
          text: Strings.login,
          height: 44.0,
          onPressed: () {
            //TODO Interact with RPC for keyfile login status
            Navigator.pushReplacementNamed(context, '/');
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addGoBackButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('go_back'),
          text: Strings.back,
          height: 44.0,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }
}
