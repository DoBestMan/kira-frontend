import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/bloc/account_bloc.dart';

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
  FocusNode accountNameFocusNode;

  TextEditingController createPasswordController;
  TextEditingController confirmPasswordController;
  TextEditingController accountNameController;

  @override
  void initState() {
    super.initState();

    this.passwordsMatch = false;
    this.createPasswordFocusNode = FocusNode();
    this.confirmPasswordFocusNode = FocusNode();
    this.accountNameFocusNode = FocusNode();

    this.createPasswordController = TextEditingController();
    this.confirmPasswordController = TextEditingController();
    this.accountNameController = TextEditingController();
    accountNameController.text = "My account";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<AccountBloc, AccountState>(
      listener: (context, state) {
        print(state.toString());
      },
      builder: (context, state) {
        return HeaderWrapper(
          childWidget: Container(
              padding: const EdgeInsets.all(30.0),
              child: BlocBuilder<AccountBloc, AccountState>(
                  builder: (context, state) {
                return Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    addHeaderText(),
                    addDescription(),
                    addPassword(),
                    if (state is AccountCreating) addLoading(),
                    addNextButton(context),
                    addGoBackButton(),
                  ],
                ));
              })),
        );
      },
    ));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Text(
          Strings.createNewAccount,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: KiraColors.black,
              fontSize: 40,
              fontWeight: FontWeight.w900),
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
            style: TextStyle(color: KiraColors.green2, fontSize: 18),
          ))
        ]));
  }

  Widget addPassword() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Strings.accountName,
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width *
                      (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    topMargin: 20,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    focusNode: accountNameFocusNode,
                    controller: accountNameController,
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
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
            SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Strings.password,
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width *
                      (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    padding: EdgeInsets.symmetric(horizontal: 15),
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
                  width: MediaQuery.of(context).size.width *
                      (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    topMargin: 20,
                    padding: EdgeInsets.symmetric(horizontal: 15),
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
                    color: KiraColors.kYellowColor,
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ));
  }

  Widget addLoading() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: CircularProgressIndicator());
  }

  Widget addNextButton(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width *
            (ResponsiveWidget.isSmallScreen(context) ? 0.32 : 0.22),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('create_account'),
          text: Strings.next,
          height: 44.0,
          onPressed: () async {
            await submitAndEncrypt(context);
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addGoBackButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (ResponsiveWidget.isSmallScreen(context) ? 0.32 : 0.22),
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

  Future<void> submitAndEncrypt(BuildContext context) async {
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
      // Create new account
      BlocProvider.of<AccountBloc>(context).add(CreateNewAccount(
          createPasswordController.text, accountNameController.text));

      Navigator.pushNamed(context, "/seed-backup");
    }
  }
}
