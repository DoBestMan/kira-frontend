import 'dart:async';
import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/helpers/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/bloc/account_bloc.dart';

class WithdrawalScreen extends StatefulWidget {
  @override
  _WithdrawalScreenState createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  TokenService tokenService = TokenService();
  GravatarService gravatarService = GravatarService();
  RPCMethodsService rpcMethodService = RPCMethodsService();

  List<Token> tokens = List();
  Account currentAccount;
  Token currentToken;
  double amountInterval;
  double withdrawalAmount;
  double transactionFee;
  String amountError;
  String addressError;
  Timer timer;

  bool copied;

  FocusNode amountFocusNode;
  TextEditingController amountController;

  FocusNode addressFocusNode;
  TextEditingController addressController;

  FocusNode memoFocusNode;
  TextEditingController memoController;

  @override
  void initState() {
    super.initState();

    this.copied = false;

    getRPCMethods();
    // tokenService.getDummyTokens();

    transactionFee = 0.05;
    withdrawalAmount = 0;

    amountError = '';
    addressError = '';

    amountFocusNode = FocusNode();
    amountController = TextEditingController();
    amountController.text = withdrawalAmount.toString();

    addressFocusNode = FocusNode();
    addressController = TextEditingController();

    memoFocusNode = FocusNode();
    memoController = TextEditingController();

    if (mounted) {
      setState(() {
        if (BlocProvider.of<AccountBloc>(context).state.currentAccount !=
            null) {
          currentAccount =
              BlocProvider.of<AccountBloc>(context).state.currentAccount;
        }
      });
    }

    getTokens();
  }

  void autoPress() {
    timer = new Timer(const Duration(seconds: 2), () {
      setState(() {
        copied = false;
      });
    });
  }

  void getTokens() async {
    if (currentAccount != null && mounted) {
      await tokenService.getTokens(currentAccount.bech32Address);

      setState(() {
        tokens = tokenService.tokens;
        currentToken = tokens.length > 0 ? tokens[0] : null;
        amountInterval = currentToken != null ? currentToken.balance / 100 : 1;
      });
    }
  }

  void getRPCMethods() async {
    await rpcMethodService.getRPCMethods();
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
                  childWidget: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    addHeaderText(),
                    if (currentAccount != null) addGravatar(context),
                    if (currentToken == null) addDescription(),
                    if (currentToken != null) addToken(context),
                    if (currentToken != null) addWithdrawalAmount(),
                    if (currentToken != null) addTransactionInformation(),
                    addWithdrawalAddress(),
                    addMemo(),
                    addWithdrawButton(),
                    addWithdrawalTransactionsTable(context),
                  ],
                ),
              ));
            }));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Text(
          "Withdrawal",
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
            "No sufficient balance for this account",
            textAlign: TextAlign.center,
            style: TextStyle(color: KiraColors.green2, fontSize: 18),
          ))
        ]));
  }

  Widget addToken(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Token",
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
                        value:
                            currentToken != null ? currentToken.assetName : "",
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 32,
                        underline: SizedBox(),
                        onChanged: (String assetName) {
                          setState(() {
                            currentToken = tokens.singleWhere(
                                (token) => token.assetName == assetName);

                            amountInterval = currentToken.balance / 100;
                            withdrawalAmount = 0;
                            amountController.text = withdrawalAmount.toString();
                          });
                        },
                        items:
                            tokens.map<DropdownMenuItem<String>>((Token token) {
                          return DropdownMenuItem<String>(
                            value: token.assetName,
                            child: Text(token.assetName,
                                style: TextStyle(
                                    color: KiraColors.kPurpleColor,
                                    fontSize: 18)),
                          );
                        }).toList()),
                  ),
                )),
          ],
        ));
  }

  Widget addWithdrawalAmount() {
    int sliderHeight = 40;
    String ticker = currentToken != null ? currentToken.ticker : "";

    return Container(
        margin: EdgeInsets.only(bottom: 0, left: 30, right: 30),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Strings.withdrawalAmount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width *
                      (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    focusNode: amountFocusNode,
                    controller: amountController,
                    textInputAction: TextInputAction.next,
                    hintText: 'Minimum Withdrawal 0.05 ' + ticker,
                    maxLines: 1,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.left,
                    // showMax: true,
                    // onHalfClicked: () {
                    //   setState(() {
                    //     amountError = "";
                    //     withdrawalAmount = amountInterval * 50;
                    //     amountController.text =
                    //         (amountInterval * 50).toStringAsFixed(6);
                    //   });
                    // },
                    // onMaxClicked: () {
                    //   setState(() {
                    //     amountError = "";
                    //     withdrawalAmount = amountInterval * 100;
                    //     amountController.text =
                    //         (amountInterval * 100).toStringAsFixed(6);
                    //   });
                    // },
                    onChanged: (String text) {
                      if (text == '' ||
                          double.parse(text, (e) => null) == null) {
                        setState(() {
                          amountError = "Withdrawal amount is invalid";
                          withdrawalAmount = 0;
                        });
                        return;
                      }

                      double percent =
                          double.parse(amountController.text) / amountInterval;

                      if (double.parse(amountController.text) < 0.25 ||
                          percent > 100) {
                        setState(() {
                          amountError = percent > 100
                              ? "Withdrawal amount is out of range"
                              : "Amount to withdraw must be at least 0.05000000 " +
                                  ticker;
                          withdrawalAmount = 0;
                        });
                        return;
                      }

                      setState(() {
                        amountError = "";
                        withdrawalAmount = double.parse(amountController.text);
                      });
                    },
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                        color: KiraColors.kBrownColor,
                        fontFamily: 'NunitoSans'),
                  ),
                ),
                Text(
                  'Available Balance ' +
                      (amountInterval * 100).toStringAsFixed(6) +
                      " " +
                      ticker,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: sliderHeight * .3,
                    fontWeight: FontWeight.w700,
                    color: KiraColors.black,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width *
                      (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  alignment: AlignmentDirectional.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'min',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: sliderHeight * .5,
                            fontWeight: FontWeight.w700,
                            color: KiraColors.kPrimaryColor,
                          ),
                        ),
                        SizedBox(
                          width: sliderHeight * .1,
                        ),
                        Expanded(
                          child: Center(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                    KiraColors.kPurpleColor.withOpacity(.7),
                                inactiveTrackColor: KiraColors
                                    .kPrimaryLightColor
                                    .withOpacity(.5),
                                trackHeight: 5.0,
                                thumbShape: CustomSliderThumbCircle(
                                  thumbRadius: sliderHeight * .4,
                                  min: 0,
                                  max: 100,
                                ),
                                overlayColor:
                                    KiraColors.kPrimaryColor.withOpacity(.4),
                                valueIndicatorShape:
                                    PaddleSliderValueIndicatorShape(),
                                valueIndicatorColor: Colors.black,
                                tickMarkShape:
                                    RoundSliderTickMarkShape(tickMarkRadius: 5),
                                activeTickMarkColor:
                                    KiraColors.kLightPurpleColor,
                                inactiveTickMarkColor: KiraColors
                                    .kPrimaryLightColor
                                    .withOpacity(.7),
                              ),
                              child: CustomSlider(
                                  value: withdrawalAmount / amountInterval,
                                  min: 0,
                                  max: 100,
                                  divisions: 4,
                                  onChanged: (value) {
                                    setState(() {
                                      withdrawalAmount = value * amountInterval;
                                      amountController.text =
                                          withdrawalAmount.toStringAsFixed(6);
                                      amountError = "";
                                    });
                                  }),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: sliderHeight * .1,
                        ),
                        Text(
                          'max',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: sliderHeight * .5,
                            fontWeight: FontWeight.w700,
                            color: KiraColors.kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget addTransactionInformation() {
    int sliderHeight = 40;
    String ticker = currentToken != null ? currentToken.ticker : "";

    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Container(
          width: MediaQuery.of(context).size.width *
              (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
          child: (Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                  "Transaction Fee: " +
                      transactionFee.toString() +
                      " " +
                      ticker,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: sliderHeight * .4,
                      fontWeight: FontWeight.w700,
                      color: KiraColors.black)),
              SizedBox(height: 10),
              Text(
                withdrawalAmount > transactionFee
                    ? 'You Will Get: ' +
                        (withdrawalAmount - transactionFee).toStringAsFixed(6) +
                        " " +
                        ticker
                    : 'You Will Get: 0.000000 ' + ticker,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: sliderHeight * .4,
                  fontWeight: FontWeight.w700,
                  color: KiraColors.black,
                ),
              ),
            ],
          )),
        ));
  }

  Widget addWithdrawalAddress() {
    return Container(
        margin: EdgeInsets.only(bottom: 10, left: 30, right: 30),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Strings.withdrawal,
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width *
                      (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    focusNode: addressFocusNode,
                    controller: addressController,
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.left,
                    onChanged: (String text) {
                      if (text == '') {
                        setState(() {
                          addressError = "";
                        });
                      }
                    },
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                        color: KiraColors.kBrownColor,
                        fontFamily: 'NunitoSans'),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget addMemo() {
    return Container(
        margin: EdgeInsets.only(bottom: 10, left: 30, right: 30),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Strings.memo,
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width *
                      (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                  margin: EdgeInsets.only(top: 10, bottom: 30),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    focusNode: memoFocusNode,
                    controller: memoController,
                    textInputAction: TextInputAction.next,
                    maxLines: null,
                    autocorrect: false,
                    keyboardType: TextInputType.multiline,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                        color: KiraColors.kBrownColor,
                        fontFamily: 'NunitoSans'),
                  ),
                ),
                if (amountError != '')
                  Container(
                    alignment: AlignmentDirectional(0, 0),
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(amountError,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: KiraColors.kYellowColor,
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                if (addressError != '')
                  Container(
                    alignment: AlignmentDirectional(0, 0),
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(addressError,
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

  Widget addGravatar(BuildContext context) {
    final String gravatar = gravatarService.getIdenticon(
        currentAccount != null ? currentAccount.bech32Address : "");

    final String reducedAddress = currentAccount.bech32Address
        .replaceRange(8, currentAccount.bech32Address.length - 4, '....');

    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                FlutterClipboard.copy(currentAccount.bech32Address)
                    .then((value) => {
                          setState(() {
                            copied = !copied;
                          }),
                          if (copied == true) {autoPress()}
                        });
              },
              borderRadius: BorderRadius.circular(500),
              onHighlightChanged: (value) {},
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: new Border.all(
                    color: KiraColors.kGrayColor,
                    width: 5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1000),
                  child: SvgPicture.string(
                    gravatar,
                    fit: BoxFit.contain,
                    width: 140,
                    height: 140,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
              child: Text(copied ? "Copied" : reducedAddress,
                  style: TextStyle(
                      color: copied
                          ? KiraColors.green2
                          : KiraColors.kLightPurpleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300)),
            ),
          ],
        ));
  }

  Widget addWithdrawButton() {
    String denomination = currentToken != null ? currentToken.denomination : "";

    return Container(
        width: MediaQuery.of(context).size.width *
            (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 100),
        child: CustomButton(
          key: Key('withdraw'),
          text: 'Withdraw',
          height: 44.0,
          onPressed: () async {
            if (withdrawalAmount == 0) {
              setState(() {
                amountError = "Please specify withdrawal amount";
              });
              return;
            }

            final message = MsgSend(
                fromAddress: currentAccount.bech32Address,
                // fromAddress: 'kira1f30dq0ux3p7japfml2jdwfwu29uhvrmdj8r899',
                toAddress: addressController.text,
                amount: [
                  StdCoin(
                      denom: denomination, amount: withdrawalAmount.toString())
                ]);

            final fee = const StdFee(gas: '200000', amount: []);

            // Generate request for encode API
            final stdEncodeMsg = await EncodeTransactionBuilder.buildEncodeTx(
                currentAccount, [message],
                stdFee: fee, memo: memoController.text);

            // Get sign_byte from /tsx/encode API
            final decodedData =
                await EncodeTransactionSender.broadcastStdEncodeTx(
                    account: currentAccount, stdEncodeMsg: stdEncodeMsg);

            if (decodedData.runtimeType == String) {
              setState(() {
                addressError = decodedData;
              });
              return;
            }
            // Check if the encoded data is same as the original request
            final isCorrect = ValidationChecker.checkDecodedMsgValidation(
                decoded: decodedData, stdEncodeMsg: stdEncodeMsg);

            if (!isCorrect) {
              setState(() {
                addressError = "Server can't verify the request";
              });
              return;
            }

            final stdTx = TransactionBuilder.buildStdTx([message], stdFee: fee);

            // Sort decoded sign_bytes json
            final sortedDecodeData = MapSorter.sort(decodedData);

            // Get bytes from the sorted json
            final signBytes = utf8.encode(jsonEncode(sortedDecodeData));

            // Sign the transaction
            final signedStdTx = await TransactionSigner.signStdTx(
                currentAccount, stdTx, signBytes);

            // Broadcast signed transaction
            final result = await TransactionSender.broadcastStdTx(
                account: currentAccount, stdTx: signedStdTx);

            if (result.runtimeType == TransactionResult) {
              print("Tx send successfully. Hash: ${result.hash}");
            } else {
              print("Tx send error: ${result.message}");
            }
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addWithdrawalTransactionsTable(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Withdrawal Transactions",
                textAlign: TextAlign.start,
                style: TextStyle(color: KiraColors.black, fontSize: 30)),
            SizedBox(height: 30),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 2,
                      color: KiraColors.kLightPurpleColor.withOpacity(0.5)),
                  color: KiraColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: KiraColors.kPurpleColor.withOpacity(0.2),
                        offset: Offset(0, 10), //Shadow starts at x=0, y=8
                        blurRadius: 8)
                  ],
                ),
                child: WithdrawalTransactionsTable())
          ],
        ));
  }
}
