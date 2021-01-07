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
  String notification;
  String faucetToken;
  List<Token> tokens = [];
  List<String> faucetTokens = [];
  String address;

  void getTokens() async {
    await tokenService.getTokens(address);
    print(tokenService.tokens);
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

  @override
  void initState() {
    super.initState();
    notification = '';
    address = '';
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
                            addTokenBalanceTable(context),
                            if (faucetTokens.length > 0) addFaucetTokens(context),
                          ],
                        ),
                      )));
            }));
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Text(
          Strings.tokenBalances,
          textAlign: TextAlign.left,
          style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
        ));
  }

  Widget addTokenBalanceTable(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Container(
        width: screenSize.width,
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: KiraColors.kGrayColor.withOpacity(0.2)),
                  color: KiraColors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                        color: KiraColors.kBrownColor.withOpacity(0.1),
                        offset: Offset(0, 5), //Shadow starts at x=0, y=8
                        blurRadius: 8)
                  ],
                ),
                child: TokenBalancesTable(tokens: tokens)),
          ],
        ));
  }

  Widget addFaucetTokens(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Faucet Tokens", style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: KiraColors.kPrimaryColor),
                        color: KiraColors.kPrimaryLightColor,
                        borderRadius: BorderRadius.circular(25)),
                    // dropdown below..
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<String>(
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
                                child: Text(token, style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 18)),
                              );
                            }).toList()),
                      ),
                    )),
                Container(
                    width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.2 : 0.08),
                    child: CustomButton(
                      key: Key('faucet'),
                      text: "Faucet",
                      height: 30.0,
                      fontSize: 15,
                      onPressed: () async {
                        if (address.length > 0) {
                          String result = await tokenService.faucet(address, faucetToken);
                          setState(() {
                            notification = result;
                          });
                        }
                      },
                    ))
              ],
            ),
            if (notification != "") SizedBox(height: 10),
            if (notification != "")
              Container(
                alignment: AlignmentDirectional(0, 0),
                margin: EdgeInsets.only(top: 3),
                child: Text(notification,
                    style: TextStyle(
                      fontSize: 17.0,
                      color: notification != "Success!" ? KiraColors.kYellowColor : KiraColors.green2,
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                    )),
              ),
          ],
        ));
  }
}
