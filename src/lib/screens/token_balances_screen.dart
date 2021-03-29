import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/models/export.dart';

class TokenBalanceScreen extends StatefulWidget {
  @override
  _TokenBalanceScreenState createState() => _TokenBalanceScreenState();
}

class _TokenBalanceScreenState extends State<TokenBalanceScreen> {
  TokenService tokenService = TokenService();
  StatusService statusService = StatusService();
  String notification = '';
  String faucetToken;
  List<Token> tokens = [];
  List<String> faucetTokens = [];
  String address = '';
  bool isNetworkHealthy = false;
  int expandedIndex = -1;
  int sortIndex = 0;
  bool isAscending = true;

  void getTokens() async {
    await tokenService.getTokens(address);

    if (mounted) {
      setState(() {
        tokens = tokenService.tokens;
      });
    }
  }

  void getFaucetTokens() async {
    Account currentAccount = BlocProvider.of<AccountBloc>(context).state.currentAccount;

    if (currentAccount != null && mounted) {
      await tokenService.getAvailableFaucetTokens();
      await tokenService.getTokens(currentAccount.bech32Address);
      setState(() {
        address = currentAccount.bech32Address;
        tokens = tokenService.tokens;
        faucetTokens = tokenService.faucetTokens;
        faucetToken = faucetTokens.length > 0 ? faucetTokens[0] : null;
      });
    }
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        if (statusService.nodeInfo.network.isNotEmpty) {
          isNetworkHealthy = statusService.isNetworkHealthy;
        } else {
          isNetworkHealthy = false;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getNodeStatus();
    getFaucetTokens();
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
                        constraints: BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            addHeaderTitle(),
                            // if (faucetTokens.length > 0) addFaucetTokens(context),
                            // addTokenBalanceTable(context),
                            addTableHeader(),
                            (tokens.isEmpty)
                                ? Container(
                                    margin: EdgeInsets.only(top: 20, left: 20),
                                    child: Text("No tokens",
                                        style: TextStyle(
                                            color: KiraColors.white, fontSize: 18, fontWeight: FontWeight.bold)))
                                : addTokenTable(),
                          ],
                        ),
                      )));
            }));
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Text(
          Strings.account,
          textAlign: TextAlign.left,
          style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
        ));
  }

  Widget addTokenBalanceTable(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Strings.tokens,
              textAlign: TextAlign.start,
              style: TextStyle(color: KiraColors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 20),
            TokenBalancesTable(tokens: tokens),
          ],
        ));
  }

  Widget faucetTokenList() {
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
                child: Text(Strings.faucetTokens, style: TextStyle(color: KiraColors.kGrayColor, fontSize: 12)),
              ),
              ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                    dropdownColor: KiraColors.kPurpleColor,
                    value: faucetToken,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 32,
                    underline: SizedBox(),
                    onChanged: (String tokenName) {
                      setState(() {
                        faucetToken = tokenName;
                      });
                    },
                    items: faucetTokens.map<DropdownMenuItem<String>>((String token) {
                      return DropdownMenuItem<String>(
                        value: token,
                        child: Container(
                            height: 25,
                            alignment: Alignment.topCenter,
                            child: Text(Tokens.getTokenFromDenom(token),
                                style: TextStyle(color: KiraColors.white, fontSize: 18))),
                      );
                    }).toList()),
              )
            ])));
  }

  Widget faucetTokenLayoutSmall() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        faucetTokenList(),
        SizedBox(height: 30),
        CustomButton(
          key: Key(Strings.faucet),
          text: Strings.faucet,
          height: 60,
          style: 2,
          fontSize: 15,
          onPressed: () async {
            if (address.length > 0) {
              String result = await tokenService.faucet(address, faucetToken);
              setState(() {
                notification = result;
              });
            }
          },
        )
      ],
    );
  }

  Widget faucetTokenLayoutBig() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: faucetTokenList()),
        SizedBox(width: 30),
        CustomButton(
          key: Key(Strings.faucet),
          text: Strings.faucet,
          width: 220,
          height: 60,
          style: 1,
          fontSize: 15,
          onPressed: () async {
            if (address.length > 0) {
              String result = await tokenService.faucet(address, faucetToken);
              setState(() {
                notification = result;
              });
            }
          },
        )
      ],
    );
  }

  Widget addFaucetTokens(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResponsiveWidget.isSmallScreen(context) ? faucetTokenLayoutSmall() : faucetTokenLayoutBig(),
            if (notification != "") SizedBox(height: 20),
            if (notification != "")
              Container(
                alignment: AlignmentDirectional(0, 0),
                margin: EdgeInsets.only(top: 3),
                child: Text(notification,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: notification != "Success!" ? KiraColors.kYellowColor.withOpacity(0.6) : KiraColors.green3,
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                    )),
              ),
          ],
        ));
  }

  Widget addTableHeader() {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(right: ResponsiveWidget.isSmallScreen(context) ? 40 : 65, bottom: 20),
      child: Row(
        children: [
          Expanded(
              flex: ResponsiveWidget.isSmallScreen(context) ? 3 : 2,
              child: InkWell(
                  onTap: () => this.setState(() {
                        if (sortIndex == 0)
                          isAscending = !isAscending;
                        else {
                          sortIndex = 0;
                          isAscending = true;
                        }
                        expandedIndex = -1;
                        refreshTableSort();
                      }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sortIndex != 0
                        ? [
                            Text("Token Name",
                                style:
                                    TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          ]
                        : [
                            Text("Token Name",
                                style:
                                    TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 5),
                            Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                          ],
                  ))),
          Expanded(
              flex: 2,
              child: InkWell(
                  onTap: () => this.setState(() {
                        if (sortIndex == 1)
                          isAscending = !isAscending;
                        else {
                          sortIndex = 1;
                          isAscending = true;
                        }
                        expandedIndex = -1;
                        refreshTableSort();
                      }),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sortIndex != 1
                          ? [
                              Text("Balance",
                                  style: TextStyle(
                                      color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            ]
                          : [
                              Text("Balance",
                                  style: TextStyle(
                                      color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(width: 5),
                              Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                            ]))),
        ],
      ),
    );
  }

  Widget addTokenTable() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TokenTable(
              tokens: tokens,
              address: address,
              expandedIndex: expandedIndex,
              onTapRow: (index) => this.setState(() {
                expandedIndex = index;
              }),
            ),
          ],
        ));
  }

  refreshTableSort() {
    this.setState(() {
      if (sortIndex == 0) {
        tokens.sort((a, b) => isAscending ? a.assetName.compareTo(b.assetName) : b.assetName.compareTo(a.assetName));
      } else if (sortIndex == 1) {
        tokens.sort((a, b) => isAscending ? a.balance.compareTo(b.balance) : b.balance.compareTo(a.balance));
      }
    });
  }
}
