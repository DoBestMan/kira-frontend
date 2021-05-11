import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:convert/convert.dart';
import 'package:kira_auth/config.dart';
import 'dart:async';
import 'dart:html' as html;

class TokenBalanceScreen extends StatefulWidget {

  @override
  _TokenBalanceScreenState createState() => _TokenBalanceScreenState();
}

class _TokenBalanceScreenState extends State<TokenBalanceScreen> {
  TokenService tokenService = TokenService();
  StatusService statusService = StatusService();
  TransactionService transactionService = TransactionService();
  String notification = '';
  String faucetToken;
  List<Token> tokens = [];
  List<String> faucetTokens = [];
  bool isNetworkHealthy = false;
  int expandedIndex = -1;
  int sortIndex = 0;
  bool isAscending = true;
  bool isLoggedIn = false;
  TextEditingController searchController;
  Account explorerAccount;
  bool isValidAddress = false;
  String searchAddress = "";
  bool isTyping = false;
  bool isSearch = false;

  Account currentAccount;
  bool copied = false;

  int tabType = 0;

  double kexBalance = 0.0;

  List<Transaction> depositTrx = [];
  List<Transaction> withdrawTrx = [];

  final List _isHovering = [false, false, false];

  var apiUrl;

  void getFaucetTokens() async {

    if (isLoggedIn) {
      currentAccount = BlocProvider.of<AccountBloc>(context).state.currentAccount;
    }

    if (currentAccount != null && mounted) {
      await tokenService.getAvailableFaucetTokens();
      await tokenService.getTokens(currentAccount.bech32Address);
      setState(() {
        tokens = tokenService.tokens;
        faucetTokens = tokenService.faucetTokens;
        faucetToken = faucetTokens.length > 0 ? faucetTokens[0] : null;

        for (int i = 0; i < tokens.length; i++) {
          if (tokens[i].ticker.toUpperCase() == "KEX") {
            this.kexBalance = tokens[i].balance;
            return;
          }
        }
      });
    }

  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        if (statusService.nodeInfo != null && statusService.nodeInfo.network.isNotEmpty) {
          isNetworkHealthy = statusService.isNetworkHealthy;
          BlocProvider.of<NetworkBloc>(context)
              .add(SetNetworkInfo(statusService.nodeInfo.network, statusService.rpcUrl));

          checkAddress(this.isSearch);
          getFaucetTokens();
        } else {
          isNetworkHealthy = false;
        }
      });
    }
  }

  void getInterxURL() async {
    apiUrl = await loadInterxURL();
  }
  Future<bool> isUserLoggedIn() async {

    isLoggedIn = await getLoginStatus();

    return isLoggedIn;

  }

  Future<bool> checkAddress(bool isSearch) async {

    if (!isSearch) {

      var uri = Uri.dataFromString(html.window.location.href); //converts string to a uri
      Map<String, String> params = uri.queryParameters; // query parameters automatically populated

      if(params.containsKey("addr")) {
        this.searchAddress = params['addr'];
      }

    }
    String hexAddress = "";

    try {
      var bech32 = Bech32Encoder.decode(this.searchAddress);

      Uint8List data = Uint8List.fromList(bech32);
      hexAddress = hex.encode(_convertBits(data, 5, 8));


      currentAccount = new Account(networkInfo: new NetworkInfo(bech32Hrp: "kira", lcdUrl: apiUrl[0] + '/cosmos'), hexAddress: hexAddress, privateKey: "", publicKey: "");

      this.depositTrx =
      await transactionService.getTransactions(account: currentAccount, max: 100, isWithdrawal: false);

      this.withdrawTrx =
      await transactionService.getTransactions(account: currentAccount, max: 100, isWithdrawal: true);


      setState(() {
        if (depositTrx.isEmpty) {
          isValidAddress = false;
        } else {
          isValidAddress = true;
        }
      });

    } catch (e) {
      setState(() {
        isValidAddress = false;
      });
          // Invalid Address
    }

    this.isSearch = false;
    //
    // try {
    //
    //   final CosmosAccount cosmosAccount =
    //   await QueryService.getAccountData(searchAccount);
    //
    //   if (cosmosAccount.address.isNotEmpty) {
    //
    //   }
    //
    // } catch (e) {
    //   print(e);
    //   isInValidAddress = true;
    // }
  }
  static Uint8List _convertBits(
      List<int> data,
      int from,
      int to, {
        bool pad = true,
      }) {
    var acc = 0;
    var bits = 0;
    final result = <int>[];
    final maxv = (1 << to) - 1;

    for (var v in data) {
      if (v < 0 || (v >> from) != 0) {
        throw Exception();
      }
      acc = (acc << from) | v;
      bits += from;
      while (bits >= to) {
        bits -= to;
        result.add((acc >> bits) & maxv);
      }
    }

    if (pad) {
      if (bits > 0) {
        result.add((acc << (to - bits)) & maxv);
      }
    } else if (bits >= from) {
      throw Exception('illegal zero padding');
    } else if (((acc << (to - bits)) & maxv) != 0) {
      throw Exception('non zero');
    }

    return Uint8List.fromList(result);
  }
  @override
  void initState() {
    super.initState();



    setTopBarStatus(true);
    getInterxURL();
    isUserLoggedIn().then((isLoggedIn) {

      setState(() {
        if (isLoggedIn){

          checkPasswordExpired().then((success) {
            if (success) {
              Navigator.pushReplacementNamed(context, '/login');
            }else {
              getNodeStatus();
            }
          });

        }else {
          getNodeStatus();
        }
      });

    });
    searchController = TextEditingController();


  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    //
    //
    // isUserLoggedIn().then((isLoggedIn) {
    //   setState(() {
    //     if (isLoggedIn){
    //       checkPasswordExpired().then((success) {
    //         if (success) {
    //           Navigator.pushReplacementNamed(context, '/login');
    //         }
    //       });
    //     }
    //   });
    //
    // });



    return Scaffold(
        body: BlocConsumer<AccountBloc, AccountState>(
            listener: (context, state) {},
            builder: (context, state) {
              return HeaderWrapper(
                  isNetworkHealthy: isNetworkHealthy,
                  childWidget: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 20, bottom: 50),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            !isLoggedIn ? addSearchInput() : Container(),
                            SizedBox(height: 30),
                            !isTyping && searchAddress != "" ? addHeaderTitle() : Container(),

                            isValidAddress ? addAccountAddress() : Container(),

                            isValidAddress ? addAccountBalance() : Container(),
                            isValidAddress ? Wrap(
                              children: tabItems(),
                            ) : Container(),
                            // if (faucetTokens.length > 0) addFaucetTokens(context),
                            // addTokenBalanceTable(context),
                            isLoggedIn || isValidAddress ? addTableHeader() : Container(),

                            isValidAddress && tabType == 0 ? addDepositTransactionsTable() : Container(),
                            isValidAddress && tabType == 1 ? addWithdrawalTransactionsTable() : Container(),
                            (isLoggedIn || (isValidAddress && tabType == 2)) ? (tokens.isEmpty)
                                ? Container(
                                    margin: EdgeInsets.only(top: 20, left: 20),
                                    child: Text("No tokens",
                                        style: TextStyle(
                                            color: KiraColors.white, fontSize: 18, fontWeight: FontWeight.bold)))
                                : addTokenTable() : Container(),
                          ],
                        ),
                      )));
            }));
  }
  Widget addSearchInput() {
    return Container(
      width: 500,
      child: AppTextField(
        hintText: Strings.validatorAccount,
        labelText: Strings.search,
        textInputAction: TextInputAction.search,
        maxLines: 1,
        autocorrect: false,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.left,
        onChanged: (String newText) {
          this.setState(() {

            isTyping = true;
            isValidAddress = false;
          });
        },

        onSubmitted: (String newText) {
          this.setState(() {
            isTyping = false;
            this.searchAddress = newText.replaceAll(" ", "");
            this.isSearch = true;
            getNodeStatus();
          });

        },
        padding: EdgeInsets.only(bottom: 15),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
          color: isTyping || isValidAddress ? KiraColors.white : KiraColors.danger,
          fontFamily: 'NunitoSans',
        ),
        topMargin: 10,
      ),
    );
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Text(
          isValidAddress ? Strings.account : Strings.searchFailed,
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
            if (this.searchAddress.length > 0) {
              String result = await tokenService.faucet(this.searchAddress, faucetToken);
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
            if (this.searchAddress.length > 0) {
              String result = await tokenService.faucet(this.searchAddress, faucetToken);
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

  Widget addAccountAddress() {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(right: ResponsiveWidget.isSmallScreen(context) ? 40 : 65, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Address",
                style:
                TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),

            InkWell(
              onTap: () {
                copyText(currentAccount.bech32Address);
                showToast(Strings.publicAddressCopied);
              },
              child: // Flexible(
              Text(currentAccount.bech32Address,
                  softWrap: true,
                  style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ]
        )
    );
  }

  Widget addAccountBalance() {
    return Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(right: ResponsiveWidget.isSmallScreen(context) ? 40 : 65, bottom: 20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Balance (KEX)",
                  style:
                  TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),

              Text(this.kexBalance.toString(),
                  style:
                  TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
            ]
        )
    );
  }

  List<Widget> tabItems() {
    List<Widget> items = [];

    for (int i = 0; i < 3; i++) {
      items.add(Container(
        margin: EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
        child: InkWell(
          onHover: (value) {
            setState(() {
              value ? _isHovering[i] = true : _isHovering[i] = false;
            });
          },
          onTap: () {
            switch (i) {
              case 0: // Deposit
                setState(() {
                  this.tabType = 0;
                });
                break;
              case 1: // Withdrawal
                setState(() {
                  this.tabType = 1;
                });
                break;
              case 2: // Tokens
                setState(() {
                  this.tabType = 2;
                });
                break;
            }
          },
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  Strings.tabItemTitles[i],
                  style: TextStyle(
                    fontSize: 15,
                    color: _isHovering[i] || i == this.tabType ? KiraColors.kYellowColor : KiraColors.kGrayColor,),
                ),
                SizedBox(height: 5),
                Visibility(
                  maintainAnimation: true,
                  maintainState: true,
                  maintainSize: true,
                  visible: _isHovering[i],
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: 3,
                    width: 30,
                    color: KiraColors.kYellowColor,
                  ),
                ),
              ]),
        ),
      ));
    }

    return items;
  }
  Widget addDepositTransactionsTable() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Strings.depositTransactions,
              textAlign: TextAlign.start,
              style: TextStyle(color: KiraColors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 20),
            DepositTransactionsTable(transactions: depositTrx)
          ],
        ));
  }
  Widget addWithdrawalTransactionsTable() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Strings.withdrawalTransactions,
              textAlign: TextAlign.start,
              style: TextStyle(color: KiraColors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 30),
            WithdrawalTransactionsTable(transactions: withdrawTrx)
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
              address: this.searchAddress,
              expandedIndex: expandedIndex,
              isLoggedIn : isLoggedIn,
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
