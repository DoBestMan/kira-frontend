// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blake_hash/blake_hash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/blocs/export.dart';

class LoginWithKeyfileScreen extends StatefulWidget {
  @override
  _LoginWithKeyfileScreenState createState() => _LoginWithKeyfileScreenState();
}

class _LoginWithKeyfileScreenState extends State<LoginWithKeyfileScreen> {
  Account account;
  String accountString, fileName, password, error;
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
        _handleKeyFile(reader.result.toString());
      });

      reader.readAsText(file);
      // reader.readAsDataUrl(file);
    });
  }

  void _handleKeyFile(String accountString) {
    setState(() {
      if (accountString.contains("encrypted_mnemonic")) {
        account = Account.fromString(accountString);
        imported = true;
      }
    });
  }

  void setImported(bool _imported) {
    setState(() {
      imported = _imported;
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
        body: HeaderWrapper(
            childWidget: Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 50, bottom: 50),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              addHeaderTitle(),
              // addDescription(),
              addKeyFileInfo(),
              addDropzone(),
              addErrorMessage(),
              ResponsiveWidget.isSmallScreen(context) ? addButtonsSmall() : addButtonsBig(),
            ],
          )),
    )));
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Text(
          Strings.loginWithKeyFile,
          textAlign: TextAlign.left,
          style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
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
            style: TextStyle(color: KiraColors.green2, fontSize: 18),
          ))
        ]));
  }

  Widget addDropzone() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500, maxHeight: 300),
                  child: DropzoneWidget(handleKeyFile: _handleKeyFile, setImported: setImported))
            ]));
  }

  Widget addKeyFileInfo() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CustomButton(
                key: Key('export'),
                isKey: true,
                width: 40.0,
                height: 40.0,
                style: 1,
                onPressed: () {
                  if (imported == true) {
                    setState(() {
                      imported = false;
                    });
                  } else {
                    _openFileExplorer();
                  }
                },
              ),
              SizedBox(width: 30),
              Expanded(
                child: CustomButton(
                  text: fileName.length > 0 ? fileName : "Log in with my key file",
                  height: 40,
                  style: 1,
                  isActive: imported,
                ),
              )
            ]));
  }

  Widget addErrorMessage() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: AlignmentDirectional(0, 0),
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

  void onLoginClick() {
    List<int> bytes = utf8.encode(password);

    // Get hash value of password and use it to encrypt mnemonic
    var hashDigest = Blake256().update(bytes).digest();
    String secretKey = String.fromCharCodes(hashDigest);

    if (account == null) {
      setState(() {
        error = Strings.invalidKeyFile;
      });
      return;
    }

    print(account.checksum);
    if (decryptAESCryptoJS(account.checksum, secretKey) == 'kira') {
      BlocProvider.of<AccountBloc>(context).add(SetCurrentAccount(account));
      BlocProvider.of<ValidatorBloc>(context).add(GetCachedValidators(account.hexAddress));

      setAccountData(account.toJsonString());
      setPassword(password);

      Navigator.pushReplacementNamed(context, '/deposit');
    } else {
      setState(() {
        error = Strings.passwordWrong;
      });
    }
  }

  Widget addButtonsBig() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CustomButton(
              key: Key('go_back'),
              text: Strings.back,
              width: 220,
              height: 60,
              style: 1,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            CustomButton(
              key: Key('log_in'),
              text: Strings.login,
              width: 220,
              height: 60,
              style: 2,
              onPressed: () {
                this.onLoginClick();
              },
            ),
          ]),
    );
  }

  Widget addButtonsSmall() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomButton(
              key: Key('log_in'),
              text: Strings.login,
              height: 60,
              style: 2,
              onPressed: () {
                this.onLoginClick();
              },
            ),
            SizedBox(height: 30),
            CustomButton(
              key: Key('go_back'),
              text: Strings.back,
              height: 60,
              style: 1,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ]),
    );
  }
}
