// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipboard/clipboard.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jdenticon/jdenticon.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/data/account_repository.dart';

class CreateNewAccountScreen extends StatefulWidget {
  CreateNewAccountScreen();

  @override
  _CreateNewAccountScreenState createState() => _CreateNewAccountScreenState();
}

class _CreateNewAccountScreenState extends State<CreateNewAccountScreen> {
  StatusService statusService = StatusService();
  IAccountRepository accountRepository = IAccountRepository();
  bool isNetworkHealthy = false;
  bool passwordsMatch, loading = false, mnemonicShown = false;

  String passwordError = "";
  Account currentAccount;
  String mnemonic;
  bool seedCopied = false;
  List<String> wordList = [];

  FocusNode createPasswordFocusNode;
  FocusNode confirmPasswordFocusNode;
  FocusNode accountNameFocusNode;
  FocusNode seedPhraseNode;

  TextEditingController seedPhraseController;
  TextEditingController createPasswordController;
  TextEditingController confirmPasswordController;
  TextEditingController accountNameController;

  @override
  void initState() {
    super.initState();

    passwordsMatch = false;
    seedPhraseNode = FocusNode();
    createPasswordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
    accountNameFocusNode = FocusNode();

    seedPhraseController = TextEditingController();
    createPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    accountNameController = TextEditingController();
    accountNameController.text = "My account";

    getNodeStatus();
  }

  @override
  void dispose() {
    seedPhraseController.dispose();
    createPasswordController.dispose();
    confirmPasswordController.dispose();
    accountNameController.dispose();
    super.dispose();
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        if (statusService.nodeInfo.network.isNotEmpty) {
          DateTime latestBlockTime = DateTime.tryParse(statusService.syncInfo.latestBlockTime);
          isNetworkHealthy = DateTime.now().difference(latestBlockTime).inMinutes > 1 ? false : true;
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
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  addHeaderTitle(),
                  addPassword(),
                  // if (currentAccount != null) addExportButton(),
                  if (currentAccount != null) addDescription(),
                  if (currentAccount != null) addPublicAddress(),
                  if (currentAccount != null) addQrButtons(),
                  if (loading) addLoadingIndicator(),
                  ResponsiveWidget.isSmallScreen(context) ? addButtonsSmall() : addButtonsBig(),
                  if (currentAccount != null && mnemonicShown == true) addMnemonicDescription(),
                  if (currentAccount != null && mnemonicShown == true) addMnemonic(),
                  if (currentAccount != null && mnemonicShown == true) addCopyButton(),
                ],
              ))),
    ));
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Text(
          Strings.createNewAccount,
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
            Strings.createAccountDescription,
            textAlign: TextAlign.left,
            style: TextStyle(color: KiraColors.green3, fontSize: 18),
          ))
        ]));
  }

  Widget addPassword() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 0),
        child: Column(
          children: [
            AppTextField(
              hintText: Strings.accountName,
              labelText: Strings.accountName,
              focusNode: accountNameFocusNode,
              controller: accountNameController,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              autocorrect: false,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                color: KiraColors.white,
                fontFamily: 'NunitoSans',
              ),
            ),
            SizedBox(height: 20),
            AppTextField(
              hintText: Strings.password,
              labelText: Strings.password,
              focusNode: createPasswordFocusNode,
              controller: createPasswordController,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              onChanged: (String newText) {
                if (passwordError.isNotEmpty) {
                  setState(() {
                    passwordError = "";
                  });
                }
                if (confirmPasswordController.text == createPasswordController.text) {
                  if (mounted) {
                    setState(() {
                      passwordsMatch = true;
                    });
                  }
                } else {
                  if (mounted) {
                    setState(() {
                      passwordsMatch = false;
                    });
                  }
                }
              },
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 23.0,
                color: KiraColors.white,
                fontFamily: 'NunitoSans',
              ),
            ),
            SizedBox(height: 20),
            AppTextField(
              hintText: Strings.confirmPassword,
              labelText: Strings.confirmPassword,
              focusNode: confirmPasswordFocusNode,
              controller: confirmPasswordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              maxLines: 1,
              autocorrect: false,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              onChanged: (String newText) {
                if (passwordError.isNotEmpty) {
                  setState(() {
                    passwordError = "";
                  });
                }
                if (confirmPasswordController.text == createPasswordController.text) {
                  if (mounted) {
                    setState(() {
                      passwordsMatch = true;
                    });
                  }
                } else {
                  if (mounted) {
                    setState(() {
                      passwordsMatch = false;
                    });
                  }
                }
              },
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 23.0,
                color: KiraColors.white,
                fontFamily: 'NunitoSans',
              ),
            ),
            if (this.passwordError.isNotEmpty) SizedBox(height: 15),
            if (this.passwordError.isNotEmpty)
              Container(
                alignment: AlignmentDirectional(0, 0),
                margin: EdgeInsets.only(bottom: 20),
                child: Text(passwordError,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: KiraColors.kYellowColor,
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                    )),
              ),
          ],
        ));
  }

  Widget addLoadingIndicator() {
    return Container(
        margin: EdgeInsets.only(bottom: 30, top: 0),
        alignment: Alignment.center,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          padding: EdgeInsets.all(0),
          child: Text(passwordError.isEmpty ? "Generating now ..." : "",
              style: TextStyle(
                fontSize: 16.0,
                color: KiraColors.kYellowColor,
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
              )),
        ));
  }

  Widget addMnemonicDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.seedPhraseDescription,
            textAlign: TextAlign.left,
            style: TextStyle(color: KiraColors.green3.withOpacity(0.8), fontSize: 15),
          ))
        ]));
  }

  Widget addMnemonic() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Container(
          child: MnemonicDisplay(
        rowNumber: ResponsiveWidget.isSmallScreen(context) ? 8 : 6,
        wordList: wordList,
        isCopied: seedCopied,
      )),
    );
  }

  Widget addCopyButton() {
    return Container(
        margin: EdgeInsets.only(bottom: 60),
        alignment: Alignment.centerLeft,
        child: CustomButton(
          key: Key('copy'),
          text: seedCopied ? Strings.copied : Strings.copy,
          width: 130,
          height: 36.0,
          style: 1,
          fontSize: 14,
          onPressed: () {
            FlutterClipboard.copy(mnemonic).then((value) => {
                  setState(() {
                    seedCopied = !seedCopied;
                  })
                });
          },
        ));
  }

  Widget addPublicAddress() {
    // final String gravatar = gravatarService.getIdenticon(currentAccount != null ? currentAccount.bech32Address : "");

    String bech32Address = currentAccount != null ? currentAccount.bech32Address : "";

    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
          InkWell(
            onTap: () {
              FlutterClipboard.copy(currentAccount.bech32Address)
                  .then((value) => {showToast(Strings.publicAddressCopied)});
            },
            borderRadius: BorderRadius.circular(500),
            onHighlightChanged: (value) {},
            child: Container(
              width: 75,
              height: 75,
              padding: EdgeInsets.all(2),
              decoration: new BoxDecoration(
                color: KiraColors.kPurpleColor,
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1000),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: SvgPicture.string(
                    Jdenticon.toSvg(currentAccount.bech32Address, 100, 10),
                    fit: BoxFit.contain,
                    height: 70,
                    width: 70,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 1,
            child: AppTextField(
              hintText: Strings.publicAddress,
              labelText: Strings.publicAddress,
              focusNode: seedPhraseNode,
              controller: seedPhraseController..text = bech32Address,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              autocorrect: false,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                color: KiraColors.white,
                fontFamily: 'NunitoSans',
              ),
            ),
          ),
        ]));
  }

  Widget addExportButtons() {
    return Expanded(
      flex: 1,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomButton(
                key: Key('export'),
                text: Strings.exportToKeyFile,
                height: 60,
                style: 2,
                fontSize: 14,
                onPressed: () {
                  setAccountData(currentAccount.toJsonString());
                  BlocProvider.of<AccountBloc>(context).add(SetCurrentAccount(currentAccount));
                  BlocProvider.of<ValidatorBloc>(context).add(GetCachedValidators(currentAccount.hexAddress));

                  final text = currentAccount.toJsonString();
                  // prepare
                  final bytes = utf8.encode(text);
                  final blob = html.Blob([bytes]);
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  final anchor = html.document.createElement('a') as html.AnchorElement
                    ..href = url
                    ..style.display = 'none'
                    ..download = currentAccount.name + '.json';
                  html.document.body.children.add(anchor);

                  // download
                  anchor.click();

                  // cleanup
                  html.document.body.children.remove(anchor);
                  html.Url.revokeObjectUrl(url);
                }),
            SizedBox(height: 30),
            CustomButton(
              key: Key('show_seed'),
              text: mnemonicShown == false ? Strings.showMnemonic : Strings.hideMnemonic,
              height: 60,
              style: 1,
              onPressed: () {
                setState(() {
                  mnemonicShown = !mnemonicShown;
                });
              },
            ),
          ]),
    );
  }

  Widget addQrCode() {
    return Container(
      width: 150,
      height: 150,
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.all(0),
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: new Border.all(
          color: KiraColors.kPurpleColor,
          width: 3,
        ),
      ),
      // dropdown below..
      child: QrImage(
        data: currentAccount != null ? currentAccount.bech32Address : '',
        embeddedImage: AssetImage(Strings.logoImage),
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size(80, 80),
        ),
        version: QrVersions.auto,
        size: 300,
      ),
    );
  }

  Widget addQrButtons() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            addQrCode(),
            SizedBox(
              width: 20,
            ),
            addExportButtons()
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
              key: Key('create_account'),
              text: currentAccount == null ? Strings.generate : Strings.generateAgain,
              height: 60,
              style: 2,
              onPressed: () async {
                setState(() {
                  loading = true;
                });

                Future.delayed(const Duration(milliseconds: 500), () async {
                  await submitAndEncrypt(context);
                });
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
              style: currentAccount == null ? 1 : 2,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            CustomButton(
              key: Key('create_account'),
              text: currentAccount == null ? Strings.generate : Strings.generateAgain,
              width: 220,
              height: 60,
              style: currentAccount == null ? 2 : 1,
              onPressed: () async {
                setState(() {
                  loading = true;
                });

                Future.delayed(const Duration(milliseconds: 500), () async {
                  await submitAndEncrypt(context);
                });
              },
            )
          ]),
    );
  }

  Future<void> submitAndEncrypt(BuildContext context) async {
    if (createPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      if (mounted) {
        setState(() {
          passwordError = Strings.passwordBlank;
        });
      }
    } else if (createPasswordController.text != confirmPasswordController.text) {
      if (mounted) {
        setState(() {
          passwordError = Strings.passwordDontMatch;
        });
      }
    } else if (createPasswordController.text.length < 5) {
      if (mounted) {
        setState(() {
          passwordError = Strings.passwordLengthShort;
        });
      }
    } else {
      // Create new account
      accountRepository.createNewAccount(createPasswordController.text, accountNameController.text).then((account) {
        // BlocProvider.of<AccountBloc>(context)
        //     .add(CreateNewAccount(currentAccount);
        setState(() {
          loading = false;
          currentAccount = account;
          mnemonic = decryptAESCryptoJS(currentAccount.encryptedMnemonic, currentAccount.secretKey);
          wordList = mnemonic.split(' ');
        });
      });
    }
  }
}
