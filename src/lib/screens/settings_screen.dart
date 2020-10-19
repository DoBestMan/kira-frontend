// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/widgets/header_wrapper.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TokenService tokenService = TokenService();
  String accountId, feeTokenName, cachedAccountString, notification;
  String expireTime;
  bool isError;
  List<Account> accounts = List();
  List<Token> tokens = List();

  FocusNode passwordFocusNode;
  TextEditingController passwordController;

  FocusNode feeAmountNode;
  TextEditingController feeAmountController;

  void getCachedAccountString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      cachedAccountString = prefs.getString('accounts');
      var array = cachedAccountString.split('---');

      for (int index = 0; index < array.length; index++) {
        if (array[index] != '') {
          Account account = Account.fromString(array[index]);
          accounts.add(account);
        }
      }

      if (BlocProvider.of<AccountBloc>(context).state.currentAccount != null) {
        accountId = BlocProvider.of<AccountBloc>(context)
            .state
            .currentAccount
            .encryptedMnemonic;
      }
    });
  }

  void getCachedExpireTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      expireTime = (prefs.getInt('expireTime') / 60000).toString();
      passwordController.text = expireTime;
    });
  }

  void getCachedFeeAmount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      feeAmountController.text = prefs.getInt('feeAmount').toString();
    });
  }

  void getTokens() async {
    Account currentAccount =
        BlocProvider.of<AccountBloc>(context).state.currentAccount;
    Token feeToken = BlocProvider.of<TokenBloc>(context).state.feeToken;

    if (currentAccount != null && mounted) {
      await tokenService.getTokens(currentAccount.bech32Address);

      setState(() {
        tokens = tokenService.tokens;
        feeTokenName = feeToken != null
            ? feeToken.assetName
            : tokenService.tokens.length > 0
                ? tokens[0].assetName
                : null;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    isError = true;
    expireTime = '0';
    notification = '';
    cachedAccountString = '';

    passwordFocusNode = FocusNode();
    passwordController = TextEditingController();

    feeAmountNode = FocusNode();
    feeAmountController = TextEditingController();

    feeAmountController.text = '1000';
    // if (BlocProvider.of<AccountBloc>(context).state.currentAccount == null) {
    //   print("Fetch cached");
    //   BlocProvider.of<AccountBloc>(context).add(GetCachedAccounts());
    // }

    getCachedAccountString();
    getCachedExpireTime();
    getCachedFeeAmount();
    getTokens();
  }

  @override
  Widget build(BuildContext context) {
    checkPasswordExpired().then((success) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
        body: BlocConsumer<AccountBloc, AccountState>(
            listener: (context, state) {},
            builder: (context, state) {
              return HeaderWrapper(
                  childWidget: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    addHeaderText(),
                    // addDescription(),
                    addAccounts(context),
                    addRemoveButton(),
                    addFeeToken(context),
                    addFeeAmount(),
                    addExpirePassword(),
                    addExportButton(),
                    addUpdateButton(),
                    addGoBackButton(),
                  ],
                ),
              ));
            }));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Text(
          Strings.settings,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: KiraColors.black,
              fontSize: 40,
              fontWeight: FontWeight.w900),
        ));
  }

  Widget addAccounts(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(Strings.currentAccount,
                style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 20)),
            Container(
                width: MediaQuery.of(context).size.width *
                    (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 2, color: KiraColors.kPrimaryColor),
                    color: KiraColors.kPrimaryLightColor,
                    borderRadius: BorderRadius.circular(25)),
                // dropdown below..
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                        value: accountId,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 32,
                        underline: SizedBox(),
                        onChanged: (String accId) {
                          setState(() {
                            accountId = accId;
                          });
                        },
                        items: accounts
                            .map<DropdownMenuItem<String>>((Account data) {
                          return DropdownMenuItem<String>(
                            value: data.encryptedMnemonic,
                            child: Text(data.name,
                                style: TextStyle(
                                    color: KiraColors.kPurpleColor,
                                    fontSize: 18)),
                          );
                        }).toList()),
                  ),
                ))
          ],
        ));
  }

  Widget addDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.removeAccountDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: KiraColors.green2, fontSize: 18),
          ))
        ]));
  }

  Widget addRemoveButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (ResponsiveWidget.isSmallScreen(context) ? 0.2 : 0.08),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('remove'),
          text: Strings.remove,
          height: 30.0,
          fontSize: 15,
          onPressed: () {
            if (accounts.isEmpty) return;
            if (accountId == null || accountId == '') return;

            var updated = accounts;
            updated.removeWhere((item) => item.encryptedMnemonic == accountId);

            String updatedString = "";

            for (int i = 0; i < updated.length; i++) {
              updatedString += updated[i].toJsonString();
              if (i < updated.length - 1) {
                updatedString += "---";
              }
            }

            setState(() {
              accounts = updated;
              accountId =
                  accounts.length > 0 ? accounts[0].encryptedMnemonic : null;
            });

            removeCachedAccount();
            setAccountData(updatedString);
          },
          backgroundColor: KiraColors.green2,
        ));
  }

  Widget addFeeToken(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Token For Fee Payment",
                style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 20)),
            Container(
                width: MediaQuery.of(context).size.width *
                    (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 2, color: KiraColors.kPrimaryColor),
                    color: KiraColors.kPrimaryLightColor,
                    borderRadius: BorderRadius.circular(25)),
                // dropdown below..
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                        value: feeTokenName,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 32,
                        underline: SizedBox(),
                        onChanged: (String assetName) {
                          setState(() {
                            feeTokenName = assetName;
                          });
                        },
                        items:
                            tokens.map<DropdownMenuItem<String>>((Token token) {
                          return DropdownMenuItem<String>(
                            value: token.assetName,
                            child: Text(token.assetName,
                                style: TextStyle(
                                    color: KiraColors.kPurpleColor,
                                    fontSize: 18)),
                          );
                        }).toList()),
                  ),
                )),
          ],
        ));
  }

  Widget addFeeAmount() {
    return Container(
        margin: EdgeInsets.only(bottom: 10, left: 30, right: 30),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Fee Amount",
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width *
                      (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    focusNode: feeAmountNode,
                    controller: feeAmountController,
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.left,
                    onChanged: (String text) {
                      if (text == '') {
                        setState(() {
                          notification = "";
                        });
                      }
                    },
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                        color: KiraColors.kBrownColor,
                        fontFamily: 'NunitoSans'),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget addExpirePassword() {
    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Password expires in",
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width *
                      (ResponsiveWidget.isSmallScreen(context) ? 0.22 : 0.17),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    topMargin: 20,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    focusNode: passwordFocusNode,
                    controller: passwordController,
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.left,
                    onChanged: (String password) {
                      if (password != "") {
                        setState(() {
                          notification = "";
                        });
                      }
                    },
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      color: KiraColors.kPrimaryColor,
                      fontFamily: 'NunitoSans',
                    ),
                  ),
                ),
                Text("minutes",
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
              ],
            ),
            if (notification != "") SizedBox(height: 10),
            if (notification != "")
              Container(
                alignment: AlignmentDirectional(0, 0),
                margin: EdgeInsets.only(top: 3),
                child: Text(notification,
                    style: TextStyle(
                      fontSize: 14.0,
                      color:
                          isError ? KiraColors.kYellowColor : KiraColors.green2,
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                    )),
              ),
          ],
        ));
  }

  Widget addExportButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (ResponsiveWidget.isSmallScreen(context) ? 0.2 : 0.1),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('export'),
          text: "Export to File",
          height: 30.0,
          fontSize: 15,
          onPressed: () {
            Account currentAccount = accounts
                .where((e) => e.encryptedMnemonic == accountId)
                .toList()[0];

            final text = currentAccount.toJsonString();
            // prepare
            final bytes = utf8.encode(text);
            final blob = html.Blob([bytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor =
                html.document.createElement('a') as html.AnchorElement
                  ..href = url
                  ..style.display = 'none'
                  ..download = currentAccount.name + '.json';
            html.document.body.children.add(anchor);

            // download
            anchor.click();

            // cleanup
            html.document.body.children.remove(anchor);
            html.Url.revokeObjectUrl(url);
          },
          backgroundColor: KiraColors.green2,
        ));
  }

  Widget addUpdateButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('update'),
          text: Strings.update,
          height: 44.0,
          onPressed: () {
            if (passwordController.text == null) return;

            int minutes = int.tryParse(passwordController.text);
            if (minutes == null) {
              this.setState(() {
                notification = "Invalid expire time. Integer only.";
                isError = true;
              });
              return;
            }

            this.setState(() {
              notification = "Successfully updated";
              isError = false;
            });

            setExpireTime(
                Duration(minutes: int.parse(passwordController.text)));

            setFeeAmount(int.parse(feeAmountController.text));

            Account currentAccount = accounts
                .where((e) => e.encryptedMnemonic == accountId)
                .toList()[0];

            BlocProvider.of<AccountBloc>(context)
                .add(SetCurrentAccount(currentAccount));

            setCurrentAccount(currentAccount.toJsonString());

            Token feeToken =
                tokens.where((e) => e.assetName == feeTokenName).toList()[0];

            BlocProvider.of<TokenBloc>(context).add(SetFeeToken(feeToken));

            setFeeToken(feeToken.toString());

            // Navigator.pushReplacementNamed(context, '/create-account');
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addGoBackButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 100),
        child: CustomButton(
          key: Key('go_back'),
          text: Strings.back,
          height: 44.0,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/deposit');
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }
}
