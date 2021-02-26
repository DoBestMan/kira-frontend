// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kira_auth/config.dart';
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
  StatusService statusService = StatusService();
  TokenService tokenService = TokenService();
  String accountId, feeTokenName, cachedAccountString = '', notification = '';
  String expireTime = '0', error = '';
  bool isError = true;
  List<Account> accounts = [];
  List<Token> tokens = [];
  bool isNetworkHealthy = false;

  FocusNode passwordFocusNode;
  TextEditingController passwordController;

  FocusNode feeAmountNode;
  TextEditingController feeAmountController;

  FocusNode rpcUrlNode;
  TextEditingController rpcUrlController;

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
        accountId = BlocProvider.of<AccountBloc>(context).state.currentAccount.encryptedMnemonic;
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
      int feeAmount = prefs.getInt('feeAmount');
      if (feeAmount.runtimeType != Null)
        feeAmountController.text = feeAmount.toString();
      else
        feeAmountController.text = "100";
    });
  }

  void getTokens() async {
    Account currentAccount = BlocProvider.of<AccountBloc>(context).state.currentAccount;
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

  void getInterxRPCUrl() async {
    rpcUrlController.text = await loadConfig();
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
  void initState() {
    super.initState();

    passwordFocusNode = FocusNode();
    passwordController = TextEditingController();

    feeAmountNode = FocusNode();
    feeAmountController = TextEditingController();
    feeAmountController.text = '1000';

    rpcUrlNode = FocusNode();
    rpcUrlController = TextEditingController();

    getNodeStatus();
    getInterxRPCUrl();
    getCachedAccountString();
    getCachedExpireTime();
    getCachedFeeAmount();
    getTokens();
  }

  void onExportClicked() {
    Account currentAccount = accounts.where((e) => e.encryptedMnemonic == accountId).toList()[0];

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
  }

  void onUpdateClicked() {
    if (passwordController.text == null) return;

    int minutes = int.tryParse(passwordController.text);
    if (minutes == null) {
      this.setState(() {
        notification = "Invalid expire time. Integer only.";
        isError = true;
      });
      return;
    }

    int feeAmount = int.tryParse(feeAmountController.text);
    if (feeAmount == null) {
      this.setState(() {
        notification = "Invalid fee amount. Integer only.";
        isError = true;
      });
      return;
    }

    String customInterxRPCUrl = rpcUrlController.text;
    if (customInterxRPCUrl == null || customInterxRPCUrl.length == 0) {
      this.setState(() {
        notification = "Interx URL should not be empty.";
        isError = true;
      });
      return;
    }

    this.setState(() {
      notification = "Successfully updated";
      isError = false;
    });

    setExpireTime(Duration(minutes: minutes));
    setInterxRPCUrl(customInterxRPCUrl);
    setFeeAmount(feeAmount);

    Account currentAccount = accounts.where((e) => e.encryptedMnemonic == accountId).toList()[0];
    BlocProvider.of<AccountBloc>(context).add(SetCurrentAccount(currentAccount));
    setCurrentAccount(currentAccount.toJsonString());

    Token feeToken = tokens.where((e) => e.assetName == feeTokenName).toList()[0];
    BlocProvider.of<TokenBloc>(context).add(SetFeeToken(feeToken));
    setFeeToken(feeToken.toString());
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
                  isNetworkHealthy: isNetworkHealthy,
                  childWidget: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 50, bottom: 50),
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            addHeaderTitle(),
                            addAccounts(),
                            addRemoveButton(context),
                            addCustomRPC(),
                            addErrorMessage(),
                            if (tokens.length > 0) addFeeToken(),
                            addFeeAmount(),
                            addExpirePassword(),
                            ResponsiveWidget.isSmallScreen(context) ? addButtonsSmall() : addButtonsBig(),
                            addGoBackButton(),
                          ],
                        )),
                  ));
            }));
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Text(
          Strings.settings,
          textAlign: TextAlign.left,
          style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
        ));
  }

  Widget addAccounts() {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 2, color: KiraColors.kPurpleColor),
            color: KiraColors.transparent,
            borderRadius: BorderRadius.circular(9)),
        // dropdown below..
        child: DropdownButtonHideUnderline(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.only(top: 10, left: 15, bottom: 0),
                child: Text(Strings.availableAccounts, style: TextStyle(color: KiraColors.kGrayColor, fontSize: 12)),
              ),
              ButtonTheme(
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
                    items: accounts.map<DropdownMenuItem<String>>((Account data) {
                      return DropdownMenuItem<String>(
                        value: data.encryptedMnemonic,
                        child: Container(
                            height: 25,
                            alignment: Alignment.topCenter,
                            child: Text(data.name, style: TextStyle(color: KiraColors.white, fontSize: 18))),
                      );
                    }).toList()),
              ),
            ],
          ),
        ));
  }

  showConfirmationDialog(BuildContext context) {
    // set up the buttons
    Widget noButton = TextButton(
      child: Text(
        Strings.no,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    Widget yesButton = TextButton(
      child: Text(
        Strings.yes,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      onPressed: () {
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
          accountId = accounts.length > 0 ? accounts[0].encryptedMnemonic : null;
        });

        removeCachedAccount();
        setAccountData(updatedString);
      },
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          contentWidgets: [
            Text(
              Strings.kiraNetwork,
              style: TextStyle(fontSize: 22, color: KiraColors.kPurpleColor, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              Strings.removeAccountConfirmation,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 22,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[yesButton, noButton]),
          ],
        );
      },
    );
  }

  Widget addRemoveButton(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 8, bottom: 30),
        alignment: Alignment.centerLeft,
        child: InkWell(
            onTap: () {
              if (accounts.isEmpty) return;
              if (accountId == null || accountId == '') return;

              showConfirmationDialog(context);
            },
            child: Text(
              Strings.remove,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: KiraColors.kGrayColor.withOpacity(0.6),
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            )));
  }

  Widget addErrorMessage() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: this.error.isNotEmpty ? 30 : 0),
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

  Widget addFeeToken() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
            border: Border.all(width: 2, color: KiraColors.kPurpleColor),
            color: KiraColors.transparent,
            borderRadius: BorderRadius.circular(9)),
        // dropdown below..
        child: DropdownButtonHideUnderline(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.only(top: 10, left: 15, bottom: 0),
                child: Text("Token For Fee Payment", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 12)),
              ),
              ButtonTheme(
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
                    items: tokens.map<DropdownMenuItem<String>>((Token token) {
                      return DropdownMenuItem<String>(
                        value: token.assetName,
                        child: Container(
                            height: 25,
                            alignment: Alignment.topCenter,
                            child: Text(token.assetName, style: TextStyle(color: KiraColors.white, fontSize: 18))),
                      );
                    }).toList()),
              ),
            ],
          ),
        ));
  }

  Widget addCustomRPC() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppTextField(
        hintText: Strings.rpcURL,
        labelText: Strings.rpcURL,
        focusNode: rpcUrlNode,
        controller: rpcUrlController,
        textInputAction: TextInputAction.done,
        maxLines: 1,
        autocorrect: false,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.left,
        onChanged: (String text) {
          setState(() {
            var urlPattern = r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,5}$";
            RegExp regex = new RegExp(urlPattern, caseSensitive: false);

            if (!regex.hasMatch(text)) {
              error = Strings.invalidUrl;
            } else {
              error = "";
            }
          });
        },
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: KiraColors.white,
          fontFamily: 'NunitoSans',
        ),
      ),
      SizedBox(height: 30),
    ]);
  }

  Widget addFeeAmount() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppTextField(
        hintText: Strings.feeAmount,
        labelText: Strings.feeAmount,
        focusNode: feeAmountNode,
        controller: feeAmountController,
        textInputAction: TextInputAction.done,
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
          fontSize: 18,
          color: KiraColors.white,
          fontFamily: 'NunitoSans',
        ),
      ),
      SizedBox(height: 30),
    ]);
  }

  Widget addExpirePassword() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppTextField(
        labelText: Strings.passwordExpresIn,
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
          fontSize: 18,
          color: KiraColors.white,
          fontFamily: 'NunitoSans',
        ),
      ),
      if (notification != "") SizedBox(height: 10),
      if (notification != "")
        Container(
          alignment: AlignmentDirectional(0, 0),
          margin: EdgeInsets.only(top: 3),
          child: Text(notification,
              style: TextStyle(
                fontSize: 14.0,
                color: isError ? KiraColors.kYellowColor : KiraColors.green2,
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
              )),
        ),
      SizedBox(height: 50),
    ]);
  }

  Widget addButtonsSmall() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomButton(
              key: Key('update'),
              text: Strings.update,
              height: 60,
              style: 2,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            SizedBox(height: 30),
            CustomButton(
              key: Key('export'),
              text: "Export to File",
              height: 60,
              style: 1,
              onPressed: () {
                this.onExportClicked();
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
              key: Key('export'),
              text: "Export to File",
              width: 220,
              height: 60,
              style: 1,
              onPressed: () {
                this.onExportClicked();
              },
            ),
            CustomButton(
              key: Key('update'),
              text: Strings.update,
              width: 220,
              height: 60,
              style: 2,
              onPressed: () {
                this.onUpdateClicked();
              },
            ),
          ]),
    );
  }

  Widget addGoBackButton() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      CustomButton(
        key: Key('go_back'),
        text: Strings.back,
        fontSize: 18,
        height: 60,
        style: 1,
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/deposit');
        },
      )
    ]);
  }
}
