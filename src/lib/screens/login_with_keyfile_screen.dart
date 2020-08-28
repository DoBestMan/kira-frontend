// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blake_hash/blake_hash.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/widgets/custom_button.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/styles.dart';
import 'package:kira_auth/utils/encrypt.dart';
import 'package:kira_auth/utils/cache.dart';
import 'package:kira_auth/models/account_model.dart';

class LoginWithKeyfileScreen extends StatefulWidget {
  @override
  _LoginWithKeyfileScreenState createState() => _LoginWithKeyfileScreenState();
}

class _LoginWithKeyfileScreenState extends State<LoginWithKeyfileScreen> {
  AccountData accountData;
  String accountDataString, fileName, password, error;
  bool imported;

  @override
  void initState() {
    super.initState();
    fileName = "";
    password = "";
    error = "";
    imported = false;
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
      imported = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    // Set password from param
    if (arguments != null && password == '') {
      setState(() {
        password = arguments['password'];
      });
    }

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
          addErrorMessage(),
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

  Widget addErrorMessage() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: AlignmentDirectional(0, 0),
                  margin: EdgeInsets.only(top: 3),
                  child: Text(this.error == null ? "" : error,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: KiraColors.kYellowColor,
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.w600,
                      )),
                ),
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
          text: imported ? "Imported" : "Import",
          height: 30.0,
          fontSize: 15,
          onPressed: () {
            if (imported == true) {
              setState(() {
                imported = false;
              });
            } else {
              _openFileExplorer();
            }
          },
          backgroundColor:
              imported ? KiraColors.kYellowColor : KiraColors.green2,
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
            List<int> bytes = utf8.encode(password);

            // Get hash value of password and use it to encrypt mnemonic
            var hashDigest = Blake256().update(bytes).digest();
            String secretKey = String.fromCharCodes(hashDigest);

            if (decryptAESCryptoJS(accountData.checksum, secretKey) == 'kira') {
              setPassword(password);
              //TODO: Redirect to view screen
            } else {
              setState(() {
                error =
                    "Password is wrong. Please go back and input correct password";
              });
            }
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
