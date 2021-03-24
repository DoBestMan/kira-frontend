// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:blake_hash/blake_hash.dart';
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
  String accountId, feeTokenTicker, notification = '';
  String expireTime = '0', error = '', accountNameError = '', currentPassword = '';
  bool isError = true, isEditEnabled = false;
  List<Account> accounts = [];
  List<Token> tokens = [];
  bool isNetworkHealthy = false;

  FocusNode expireTimeFocusNode;
  TextEditingController expireTimeController;

  FocusNode feeAmountNode;
  TextEditingController feeAmountController;

  FocusNode rpcUrlNode;
  TextEditingController rpcUrlController;

  FocusNode accountNameNode;
  TextEditingController accountNameController;

  FocusNode passwordNode;
  TextEditingController passwordController;

  void readCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      String cachedAccountString = prefs.getString('accounts');
      var array = cachedAccountString.split('---');

      for (int index = 0; index < array.length; index++) {
        if (array[index] != '') {
          Account account = Account.fromString(array[index]);
          accounts.add(account);
        }
      }

      if (BlocProvider.of<AccountBloc>(context).state.currentAccount != null) {
        accountId = BlocProvider.of<AccountBloc>(context).state.currentAccount.encryptedMnemonic;
        accountNameController.text = BlocProvider.of<AccountBloc>(context).state.currentAccount.name;
      }

      // Cached password
      currentPassword = prefs.getString('password');

      // Password expire time
      expireTime = (prefs.getInt('expireTime') / 60000).toString();
      expireTimeController.text = expireTime;

      // Fee amount
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
        feeTokenTicker = feeToken != null
            ? feeToken.ticker
            : tokenService.tokens.length > 0
                ? tokens[0].ticker
                : null;
      });
    }
  }

  void getInterxRPCUrl() async {
    rpcUrlController.text = await loadInterxURL();
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

    expireTimeFocusNode = FocusNode();
    expireTimeController = TextEditingController();

    feeAmountNode = FocusNode();
    feeAmountController = TextEditingController();
    feeAmountController.text = '1000';

    rpcUrlNode = FocusNode();
    rpcUrlController = TextEditingController();

    accountNameNode = FocusNode();
    accountNameController = TextEditingController();

    passwordNode = FocusNode();
    passwordController = TextEditingController();

    getNodeStatus();
    getInterxRPCUrl();
    readCachedData();
    getTokens();
  }

  @override
  void dispose() {
    expireTimeController.dispose();
    feeAmountController.dispose();
    rpcUrlController.dispose();
    accountNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void exportToKeyFile() async {
    var index = accounts.indexWhere((item) => item.encryptedMnemonic == accountId);
    if (index < 0) return;
    Account selectedAccount = new Account.fromJson(accounts[index].toJson());

    List<int> passwordBytes = utf8.encode(currentPassword);
    var hashDigest = Blake256().update(passwordBytes).digest();
    String secretKey = String.fromCharCodes(hashDigest);

    selectedAccount.secretKey = secretKey;
    selectedAccount.encryptedMnemonic = encryptAESCryptoJS(selectedAccount.encryptedMnemonic, secretKey);
    selectedAccount.checksum = encryptAESCryptoJS(selectedAccount.checksum, secretKey);

    final text = selectedAccount.toJsonString();
    // prepare
    final bytes = utf8.encode(text);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = selectedAccount.name + '.json';
    html.document.body.children.add(anchor);

    // download
    anchor.click();

    // cleanup
    html.document.body.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  void onUpdate() {
    if (expireTimeController.text == null) return;

    int minutes = int.tryParse(expireTimeController.text);
    if (minutes == null) {
      this.setState(() {
        notification = Strings.invalidExpireTime;
        isError = true;
      });
      return;
    }

    int feeAmount = int.tryParse(feeAmountController.text);
    if (feeAmount == null) {
      this.setState(() {
        notification = Strings.invalidFeeAmount;
        isError = true;
      });
      return;
    }

    String customInterxRPCUrl = rpcUrlController.text;
    if (customInterxRPCUrl == null || customInterxRPCUrl.length == 0) {
      this.setState(() {
        notification = Strings.invalidCustomRpcURL;
        isError = true;
      });
      return;
    }

    this.setState(() {
      notification = Strings.updateSuccess;
      isError = false;
    });

    setExpireTime(Duration(minutes: minutes));
    setInterxRPCUrl(customInterxRPCUrl);
    setFeeAmount(feeAmount);

    Account currentAccount = accounts.where((e) => e.encryptedMnemonic == accountId).toList()[0];
    BlocProvider.of<AccountBloc>(context).add(SetCurrentAccount(currentAccount));
    setCurrentAccount(currentAccount.toJsonString());

    Token feeToken = tokens.where((e) => e.ticker == feeTokenTicker).toList()[0];
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
                            addButtons(context),
                            if (isEditEnabled) addAccountName(),
                            if (isEditEnabled) addFinishButton(),
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
                    dropdownColor: KiraColors.kPurpleColor,
                    value: accountId,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 32,
                    underline: SizedBox(),
                    onChanged: (String accId) {
                      var curIndex = accounts.indexWhere((e) => e.encryptedMnemonic == accId);
                      if (curIndex < 0) return;
                      Account selectedAccount = new Account.fromJson(accounts[curIndex].toJson());
                      setState(() {
                        accountId = accId;
                        accountNameController.text = selectedAccount.name;
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

  Widget addButtons(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 8, bottom: 30),
        alignment: Alignment.centerLeft,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
          InkWell(
              onTap: () {
                if (accounts.isEmpty) return;
                if (accountId == null || accountId == '') return;

                showConfirmationDialog(context);
              },
              child: Text(
                Strings.remove,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: KiraColors.green3.withOpacity(0.9),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              )),
          SizedBox(width: 10),
          InkWell(
              onTap: () {
                setState(() {
                  isEditEnabled = true;
                });
              },
              child: Text(
                Strings.edit,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: KiraColors.green3.withOpacity(0.9),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              )),
        ]));
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
                child: Text(Strings.tokenForFeePayment, style: TextStyle(color: KiraColors.kGrayColor, fontSize: 12)),
              ),
              ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                    dropdownColor: KiraColors.kPurpleColor,
                    value: feeTokenTicker,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 32,
                    underline: SizedBox(),
                    onChanged: (String ticker) {
                      setState(() {
                        feeTokenTicker = ticker;
                      });
                    },
                    items: tokens.map<DropdownMenuItem<String>>((Token token) {
                      return DropdownMenuItem<String>(
                        value: token.ticker,
                        child: Container(
                            height: 25,
                            alignment: Alignment.topCenter,
                            child: Text(token.ticker, style: TextStyle(color: KiraColors.white, fontSize: 18))),
                      );
                    }).toList()),
              ),
            ],
          ),
        ));
  }

  Widget addAccountName() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppTextField(
        hintText: Strings.accountName,
        labelText: Strings.accountName,
        focusNode: accountNameNode,
        controller: accountNameController,
        textInputAction: TextInputAction.done,
        maxLines: 1,
        autocorrect: false,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: KiraColors.white,
          fontFamily: 'NunitoSans',
        ),
      ),
      SizedBox(height: 10),
    ]);
  }

  Widget addFinishButton() {
    return Container(
        margin: EdgeInsets.only(top: 5, bottom: 25),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
                onTap: () {
                  var accountName = accountNameController.text;
                  if (accountName == "") {
                    setState(() {
                      accountNameError = Strings.accountNameInvalid;
                    });
                    return;
                  }

                  var index = accounts.indexWhere((item) => item.encryptedMnemonic == accountId);
                  accounts.elementAt(index).name = accountName;

                  String updatedString = "";

                  for (int i = 0; i < accounts.length; i++) {
                    updatedString += accounts[i].toJsonString();
                    if (i < accounts.length - 1) {
                      updatedString += "---";
                    }
                  }

                  removeCachedAccount();
                  setAccountData(updatedString);

                  Account currentAccount = accounts.where((e) => e.encryptedMnemonic == accountId).toList()[0];
                  BlocProvider.of<AccountBloc>(context).add(SetCurrentAccount(currentAccount));
                  setCurrentAccount(currentAccount.toJsonString());

                  setState(() {
                    isEditEnabled = false;
                  });
                },
                child: Text(
                  Strings.finish,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: KiraColors.blue1.withOpacity(0.9),
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                )),
            if (accountNameError.isNotEmpty)
              Text(accountNameError,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: KiraColors.kYellowColor,
                  ))
          ],
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
      SizedBox(height: 10),
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
        labelText: Strings.passwordExpiresIn,
        focusNode: expireTimeFocusNode,
        controller: expireTimeController,
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
                color: isError ? KiraColors.kYellowColor : KiraColors.green3,
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
              key: Key(Strings.update),
              text: Strings.update,
              height: 60,
              style: 2,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            SizedBox(height: 30),
            CustomButton(
              key: Key(Strings.exportToKeyFile),
              text: Strings.exportToKeyFile,
              height: 60,
              style: 1,
              onPressed: () async {
                if (currentPassword == "12345678") {
                  showPasswordDialog(context);
                } else {
                  exportToKeyFile();
                }
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
              key: Key(Strings.exportToKeyFile),
              text: Strings.exportToKeyFile,
              width: 220,
              height: 60,
              style: 1,
              onPressed: () {
                if (currentPassword == "12345678") {
                  showPasswordDialog(context);
                } else {
                  exportToKeyFile();
                }
              },
            ),
            CustomButton(
              key: Key(Strings.update),
              text: Strings.update,
              width: 220,
              height: 60,
              style: 2,
              onPressed: () {
                this.onUpdate();
              },
            ),
          ]),
    );
  }

  Widget addGoBackButton() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      CustomButton(
        key: Key(Strings.back),
        text: Strings.back,
        fontSize: 18,
        height: 60,
        style: 1,
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/account');
        },
      )
    ]);
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

        if (updatedString.isEmpty) {
          removePassword();
          Navigator.pushReplacementNamed(context, '/');
        }
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

  showPasswordDialog(BuildContext context) {
    // set up the buttons
    Widget closeButton = TextButton(
      child: Text(
        Strings.close,
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
        exportToKeyFile();
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
              Strings.inputPassword,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 22,
            ),
            ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: TextField(
                    focusNode: passwordNode,
                    controller: passwordController,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    obscureText: true,
                    onChanged: (String password) {
                      if (password != "") {
                        setState(() {
                          currentPassword = password;
                        });
                      }
                    },
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(color: KiraColors.kGrayColor.withOpacity(0.3), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: KiraColors.kPurpleColor, width: 2),
                      ),
                    ))),
            SizedBox(
              height: 22,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[yesButton, closeButton]),
          ],
        );
      },
    );
  }
}
