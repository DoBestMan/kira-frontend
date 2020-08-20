import 'package:flutter/material.dart';
import 'package:kira_auth/widgets/custom_button.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/styles.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/widgets/app_text_field.dart';

class CreateNewAccountScreen extends StatefulWidget {
  final String seed;
  CreateNewAccountScreen({this.seed});
  @override
  _CreateNewAccountScreenState createState() => _CreateNewAccountScreenState();
}

class _CreateNewAccountScreenState extends State<CreateNewAccountScreen> {
  String passwordError;
  bool passwordsMatch;

  FocusNode createPasswordFocusNode;
  FocusNode confirmPasswordFocusNode;
  TextEditingController createPasswordController;
  TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    this.passwordsMatch = false;
    this.createPasswordFocusNode = FocusNode();
    this.confirmPasswordFocusNode = FocusNode();
    this.createPasswordController = TextEditingController();
    this.confirmPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AppbarWrapper(
            childWidget: Container(
      padding: const EdgeInsets.all(30.0),
      child: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          addHeadText(),
          addDescription(),
          addPassword(),
          addNextButton(),
          addGoBackButton(),
        ],
      )),
    )));
  }

  Widget addHeadText() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Text(
          Strings.createNewAccount,
          style: TextStyle(color: KiraColors.kPrimaryColor, fontSize: 30),
        ));
  }

  Widget addDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.passwordDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: KiraColors.kYellowColor, fontSize: 18),
          ))
        ]));
  }

  Widget addPassword() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Strings.password,
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                        color: KiraColors.kPrimaryColor,
                        fontFamily: 'NunitoSans'),
                    onSubmitted: (text) {
                      confirmPasswordFocusNode.requestFocus();
                    },
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Strings.confirmPassword,
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    topMargin: 20,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    focusNode: confirmPasswordFocusNode,
                    controller: confirmPasswordController,
                    textInputAction: TextInputAction.done,
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
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      color: KiraColors.kPrimaryColor,
                      fontFamily: 'NunitoSans',
                    ),
                  ),
                )
              ],
            ),
            Container(
              alignment: AlignmentDirectional(0, 0),
              margin: EdgeInsets.only(top: 3),
              child: Text(this.passwordError == null ? "" : passwordError,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: KiraColors.kPrimaryColor,
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ));
  }

  Widget addNextButton() {
    return Container(
        width: MediaQuery.of(context).size.width * 0.22,
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('create_account'),
          text: Strings.next,
          height: 44.0,
          onPressed: () async {
            await submitAndEncrypt();
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addGoBackButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.32 : 0.22),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('go_back'),
          text: Strings.back,
          height: 44.0,
          onPressed: () {
            Navigator.of(context).pop();
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Future<void> submitAndEncrypt() async {
    if (createPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      if (mounted) {
        setState(() {
          passwordError = Strings.passwordBlank;
        });
      }
    } else if (createPasswordController.text !=
        confirmPasswordController.text) {
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
      Navigator.pushNamed(context, "/seed-backup",
          arguments: {'password': '${createPasswordController.text}'});
    }
  }
}
