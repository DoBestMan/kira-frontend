import 'package:flutter/material.dart';
import 'package:kira_auth/utils/cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kira_auth/models/account_model.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/widgets/custom_button.dart';
import 'package:kira_auth/widgets/app_text_field.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/styles.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String accountId, cachedAccountString = '', passwordError;
  String expireTime;
  List<AccountData> accounts = List();

  FocusNode passwordFocusNode;
  TextEditingController passwordController;

  void getCachedAccountString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cachedAccountString = prefs.getString('accounts');

      var array = cachedAccountString.split('---');

      for (int index = 0; index < array.length; index++) {
        if (array[index] != '') {
          accounts.add(AccountData.fromString(array[index]));
        }
      }
    });
  }

  void getCachedExpireTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      expireTime = prefs.getString('expire');
    });
  }

  @override
  void initState() {
    super.initState();
    getCachedAccountString();
    getCachedExpireTime();

    this.expireTime = '0';
    this.passwordFocusNode = FocusNode();
    this.passwordController = TextEditingController();
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
          addDescription(),
          addAccounts(context),
          addRemoveButton(),
          addRemovePassword(),
          addUpdateButton(),
        ],
      ),
    )));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Text(
          Strings.settings,
          textAlign: TextAlign.center,
          style: TextStyle(color: KiraColors.kPrimaryColor, fontSize: 30),
        ));
  }

  Widget addAccounts(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(Strings.accounts,
                style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 20)),
            Container(
                width: MediaQuery.of(context).size.width *
                    (smallScreen(context) ? 0.62 : 0.32),
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
                            .map<DropdownMenuItem<String>>((AccountData data) {
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
            style: TextStyle(color: KiraColors.kYellowColor, fontSize: 18),
          ))
        ]));
  }

  Widget addRemoveButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.2 : 0.08),
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
              updatedString += updated[i].toString();
              if (i < updated.length - 1) {
                updatedString += "---";
              }
            }
            setState(() {
              accounts = updated;
            });
            removeCachedAccount();
            setAccountData(updatedString);
          },
          backgroundColor: KiraColors.green2,
        ));
  }

  Widget addRemovePassword() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 30),
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
                      (smallScreen(context) ? 0.22 : 0.17),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    topMargin: 20,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    focusNode: passwordFocusNode,
                    controller: passwordController..text = expireTime,
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.left,
                    onChanged: (String password) {
                      if (password != "") {
                        setState(() {
                          passwordError = null;
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
                Text("hours",
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
              ],
            ),
            SizedBox(height: 10),
            Container(
              alignment: AlignmentDirectional(0, 0),
              margin: EdgeInsets.only(top: 3),
              child: Text(this.passwordError == null ? "" : passwordError,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: KiraColors.kYellowColor,
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ));
  }

  Widget addUpdateButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('update'),
          text: Strings.update,
          height: 44.0,
          onPressed: () {
            //TODO: Implement update
            if (passwordController.text == null) return;
            print(passwordController.text);
            setExpireTime(passwordController.text);
            // Navigator.pushReplacementNamed(context, '/create-account');
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }
}
