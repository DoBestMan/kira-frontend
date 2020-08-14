import 'package:flutter/material.dart';
import 'package:kira_auth/widgets/custom_button.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/widgets/app_text_field.dart';

class CreateNewAccountScreen extends StatefulWidget {
  @override
  _CreateNewAccountScreenState createState() => _CreateNewAccountScreenState();
}

class _CreateNewAccountScreenState extends State<CreateNewAccountScreen> {
  String _seed;
  List<String> _mnemonic;
  bool _showMnemonic;

  String networkId;

  FocusNode createPasswordFocusNode;
  TextEditingController createPasswordController;
  FocusNode confirmPasswordFocusNode;
  TextEditingController confirmPasswordController;

  String passwordError;
  bool passwordsMatch;

  @override
  void initState() {
    super.initState();
    _showMnemonic = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AppbarWrapper(
            childWidget: Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          addHeadText(),
          addNetworkId(context),
          addPassword(),
          addLoginWithMnemonic(),
          addLoginWithKeyFile(),
        ],
      ),
    )));
  }

  Widget addHeadText() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Text(
          Strings.createNewAccount,
          style: TextStyle(color: KiraColors.kPrimaryColor, fontSize: 30),
        ));
  }

  Widget addPassword() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Row(
              children: [
                Text(Strings.password,
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: 250,
                  child: AppTextField(
                    topMargin: 30,
                    padding: EdgeInsetsDirectional.only(start: 16, end: 16),
                    focusNode: createPasswordFocusNode,
                    controller: createPasswordController,
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                    autocorrect: false,
                    onChanged: (String newText) {
                      if (passwordError != null) {
                        setState(() {
                          passwordError = null;
                        });
                      }
                      if (confirmPasswordController.text ==
                          createPasswordController.text) {
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
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      color: KiraColors.blue1,
                      fontFamily: 'NunitoSans',
                    ),
                    onSubmitted: (text) {
                      confirmPasswordFocusNode.requestFocus();
                    },
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget addCreateNewAccount() {
    return CustomButton(
      key: Key('create_account'),
      text: Strings.createNewAccount,
      height: 44.0,
      onPressed: () {
        print("Strings.createNewAccount");
      },
      backgroundColor: KiraColors.kPrimaryColor,
    );
  }

  Widget addLoginWithMnemonic() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('login_with_mnemonic'),
          text: Strings.createAccount,
          height: 44.0,
          onPressed: () {
            print("Strings.loginWithMnemonic");
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addLoginWithKeyFile() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('login_with_keyfile'),
          text: Strings.loginWithKeyFile,
          height: 44.0,
          onPressed: () {
            print("Strings.loginWithKeyFile");
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addNetworkId(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(Strings.networkId,
                style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 20)),
            Container(
                width: 250,
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 2, color: KiraColors.kPrimaryColor),
                    color: KiraColors.kPrimaryLightColor,
                    borderRadius: BorderRadius.circular(20)),
                // dropdown below..
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                        value: networkId,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 32,
                        underline: SizedBox(),
                        onChanged: (String netId) {
                          setState(() {
                            networkId = netId;
                          });
                        },
                        items: <String>['One', 'Two', 'Three', 'Four']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
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
}
