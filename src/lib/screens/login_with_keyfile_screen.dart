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
import 'package:kira_auth/services/export.dart';

class LoginWithKeyfileScreen extends StatefulWidget {
  @override
  _LoginWithKeyfileScreenState createState() => _LoginWithKeyfileScreenState();
}

class _LoginWithKeyfileScreenState extends State<LoginWithKeyfileScreen> {
  StatusService statusService = StatusService();
  Account account;
  String accountString, fileName, password, error;
  bool imported = false;
  bool isNetworkHealthy = false;

  FocusNode passwordFocusNode;
  TextEditingController passwordController;

  @override
  void initState() {
    super.initState();

    fileName = "";
    password = "";
    error = "";

    passwordFocusNode = FocusNode();
    passwordController = TextEditingController();
    getNodeStatus();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
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
    });
  }

  void _handleKeyFile(String accountString) {
    setState(() {
      if (accountString.contains("encrypted_mnemonic")) {
        account = Account.fromString(accountString);
        imported = true;
        error = "";
      }
    });
  }

  void setImported(bool _imported) {
    setState(() {
      imported = _imported;
    });
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        if (statusService.nodeInfo != null && statusService.nodeInfo.network.isNotEmpty) {
          isNetworkHealthy = statusService.isNetworkHealthy;
          BlocProvider.of<NetworkBloc>(context)
              .add(SetNetworkInfo(statusService.nodeInfo.network, statusService.rpcUrl));
        } else {
          isNetworkHealthy = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: HeaderWrapper(
            isNetworkHealthy: isNetworkHealthy,
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
                      addDropzone(),
                      // addKeyFileInfo(),
                      addPassword(),
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
            style: TextStyle(color: KiraColors.green3, fontSize: 18),
          ))
        ]));
  }

  Widget addPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          hintText: Strings.password,
          labelText: Strings.password,
          focusNode: passwordFocusNode,
          controller: passwordController,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          autocorrect: false,
          keyboardType: TextInputType.text,
          obscureText: true,
          textAlign: TextAlign.left,
          onChanged: (String text) {
            if (text != "") {
              setState(() {
                password = text;
              });
            }
          },
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 23.0,
            color: KiraColors.white,
            fontFamily: 'NunitoSans',
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget addDropzone() {
    return Container(
        margin: EdgeInsets.only(bottom: 20),
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
              Expanded(
                child: CustomButton(
                  text: fileName.length > 0 ? fileName : "or Upload a key file",
                  height: 40,
                  style: 1,
                  isActive: imported,
                ),
              ),
              SizedBox(width: 30),
              CustomButton(
                key: Key(Strings.exportToKeyFile),
                isKey: true,
                width: 50.0,
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
            ]));
  }

  Widget addErrorMessage() {
    return Container(
        margin: EdgeInsets.only(top: this.error.isNotEmpty ? 10 : 0, bottom: this.error.isNotEmpty ? 30 : 0),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: AlignmentDirectional(0, 0),
                  child: Text(this.error.isEmpty ? "" : error,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: KiraColors.kYellowColor,
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.w400,
                      )),
                ),
              ],
            ),
          ],
        ));
  }

  void onLoginClick() {
    if (password == "") {
      this.setState(() {
        error = Strings.passwordBlank;
      });
      return;
    }

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

    if (decryptAESCryptoJS(account.checksum, secretKey) == 'kira') {
      BlocProvider.of<AccountBloc>(context).add(SetCurrentAccount(account));
      BlocProvider.of<ValidatorBloc>(context).add(GetCachedValidators(account.hexAddress));

      account.encryptedMnemonic = decryptAESCryptoJS(account.encryptedMnemonic, secretKey);
      account.checksum = decryptAESCryptoJS(account.checksum, secretKey);
      setAccountData(account.toJsonString());
      setPassword(password);



      setLoginStatus(true);

      Navigator.pushReplacementNamed(context, '/account');
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
              key: Key(Strings.back),
              text: Strings.back,
              width: 220,
              height: 60,
              style: 1,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            CustomButton(
              key: Key(Strings.login),
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
              key: Key(Strings.login),
              text: Strings.login,
              height: 60,
              style: 2,
              onPressed: () {
                this.onLoginClick();
              },
            ),
            SizedBox(height: 30),
            CustomButton(
              key: Key(Strings.back),
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
