import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/blocs/export.dart';

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
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 50, bottom: 50),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
                return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        addHeaderTitle(),
                        addDescription(),
                        addPassword(),
                        if (state is AccountCreating) addLoading(),
                        ResponsiveWidget.isSmallScreen(context) ? addButtonsSmall() : addButtonsBig(),
                      ],
                    ));
              })),
        );
      },
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
            Strings.passwordDescription,
            textAlign: TextAlign.left,
            style: TextStyle(color: KiraColors.green3, fontSize: 18),
          ))
        ]));
  }

  Widget addPassword() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            AppTextField(
              hintText: Strings.accountName,
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
              focusNode: createPasswordFocusNode,
              controller: createPasswordController,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              autocorrect: false,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              onChanged: (String newText) {
                if (passwordError != null) {
                  setState(() {
                    passwordError = null;
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
                fontSize: 18.0,
                color: KiraColors.white,
                fontFamily: 'NunitoSans',
              ),
            ),
            SizedBox(height: 20),
            AppTextField(
              hintText: Strings.confirmPassword,
              focusNode: confirmPasswordFocusNode,
              controller: confirmPasswordController,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              autocorrect: false,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              onChanged: (String newText) {
                if (passwordError != null) {
                  setState(() {
                    passwordError = null;
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
                fontSize: 18.0,
                color: KiraColors.white,
                fontFamily: 'NunitoSans',
              ),
            ),
            SizedBox(height: 15),
            Container(
              alignment: AlignmentDirectional(0, 0),
              margin: EdgeInsets.only(bottom: 20),
              child: Text(this.passwordError == null ? "" : passwordError,
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

  Widget addLoading() {
    return Container(margin: EdgeInsets.only(bottom: 30), child: CircularProgressIndicator());
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
              height: 70,
              style: 1,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              backgroundColor: KiraColors.kPrimaryColor,
            ),
            CustomButton(
              key: Key('create_account'),
              text: Strings.next,
              width: 220,
              height: 70,
              style: 2,
              onPressed: () async {
                await submitAndEncrypt(context);
              },
              backgroundColor: KiraColors.kPrimaryColor,
            )
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
              text: Strings.next,
              height: 70,
              style: 2,
              onPressed: () async {
                await submitAndEncrypt(context);
              },
              backgroundColor: KiraColors.kPrimaryColor,
            ),
            SizedBox(height: 30),
            CustomButton(
              key: Key('go_back'),
              text: Strings.back,
              height: 70,
              style: 1,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              backgroundColor: KiraColors.kPrimaryColor,
            ),
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
      BlocProvider.of<AccountBloc>(context)
          .add(CreateNewAccount(createPasswordController.text, accountNameController.text));

      Navigator.pushNamed(context, "/seed-backup");
    }
  }
}
