import 'package:flutter/material.dart';
import 'package:kira_auth/models/sync_info_model.dart';
import 'package:kira_auth/models/node_info_model.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/widgets/custom_button.dart';
import 'package:kira_auth/widgets/app_text_field.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/responsive.dart';
import 'package:kira_auth/services/status_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String networkId;
  List<String> networkIds = [];
  String passwordError;
  NodeInfoModel nodeInfo;
  SyncInfoModel syncInfo;
  bool loading;
  bool isNetworkHealthy;

  FocusNode passwordFocusNode;
  TextEditingController passwordController;

  @override
  void initState() {
    loading = true;
    isNetworkHealthy = true;
    super.initState();

    this.passwordFocusNode = FocusNode();
    this.passwordController = TextEditingController();
    getNodeStatus();
  }

  void getNodeStatus() async {
    StatusService statusService = StatusService();
    await statusService.getNodeStatus();

    nodeInfo = statusService.nodeInfo;
    syncInfo = statusService.syncInfo;

    DateTime latestBlockTime = DateTime.parse(syncInfo.latestBlockTime);

    if (mounted) {
      setState(() {
        loading = false;
        networkIds.add(nodeInfo.network);
        networkId = nodeInfo.network;

        isNetworkHealthy =
            DateTime.now().difference(latestBlockTime).inMinutes > 1
                ? false
                : true;
      });
    }
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
          // addDescription(),
          addNetworkId(context),
          addPassword(),
          addCreateNewAccount(),
          addLoginWithMnemonic(),
          addLoginWithKeyFile(),
        ],
      ),
    )));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Text(
          Strings.login,
          textAlign: TextAlign.center,
          style: TextStyle(color: KiraColors.kPrimaryColor, fontSize: 30),
        ));
  }

  Widget addPassword() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
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
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    focusNode: passwordFocusNode,
                    controller: passwordController,
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    obscureText: true,
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
                )
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

  Widget addNetworkId(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(Strings.networkId,
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
                        value: networkId,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 32,
                        underline: SizedBox(),
                        onChanged: (String netId) {
                          setState(() {
                            networkId = netId;
                          });
                        },
                        items: networkIds
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
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: isNetworkHealthy == null ? () {} : null,
                  child: Row(
                    children: [
                      SizedBox(width: 20, height: 20),
                      Text(
                        "NETWORK STATUS : ",
                        style: TextStyle(
                          color: KiraColors.kYellowColor,
                        ),
                      ),
                      InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.circle,
                            size: 15.0,
                            color: isNetworkHealthy == true
                                ? KiraColors.green3
                                : KiraColors.orange3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
          ],
        ));
  }

  Widget addDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.networkDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: KiraColors.kYellowColor, fontSize: 18),
          ))
        ]));
  }

  Widget addCreateNewAccount() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('create_account'),
          text: Strings.createNewAccount,
          height: 44.0,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/create-account');
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addLoginWithMnemonic() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('login_with_mnemonic'),
          text: Strings.loginWithMnemonic,
          height: 44.0,
          onPressed: () {
            if (passwordController.text != "") {
              Navigator.pushReplacementNamed(context, '/login-mnemonic',
                  arguments: {'password': '${passwordController.text}'});
            } else {
              this.setState(() {
                passwordError = "Password required";
              });
            }
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addLoginWithKeyFile() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('login_with_keyfile'),
          text: Strings.loginWithKeyFile,
          height: 44.0,
          onPressed: () {
            if (passwordController.text != "") {
              Navigator.pushReplacementNamed(context, '/login-keyfile',
                  arguments: {'password': '${passwordController.text}'});
            } else {
              this.setState(() {
                passwordError = "Password required";
              });
            }
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }
}
