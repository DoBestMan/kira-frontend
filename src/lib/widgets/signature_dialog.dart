import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:kira_auth/helpers/tx_offline_signer.dart';
import 'package:kira_auth/helpers/tx_sender.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/models/transactions/messages/msg_send.dart';
import 'package:kira_auth/models/transactions/std_coin.dart';
import 'package:kira_auth/models/transactions/std_fee.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/webcam/qr_code_scanner_web.dart';
import 'package:kira_auth/webcam/qr_code_scanner_web_impl.dart';
import 'package:saifu_fast_qr/saifu_fast_qr.dart';

class SignatureDialog extends StatefulWidget {
  MsgSend message;
  StdCoin feeV;
  StdFee fee;
  //String memo;
  StdTx stdTx;
  Account current;
  dynamic sortedJson;
  var retrievedData;

  var stdMsgData = [];
  double rating = 100;
  SignatureDialog({@required this.current, @required this.message, @required this.feeV, @required this.fee, @required this.stdTx, @required this.sortedJson});
  var currentStep = 0;

  @override
  _SignatureDialogState createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  List<String> webcamQRData = [];
  int max = 0;
  double percentage = 0;
  int stepper = 0;
  bool loadedData;
  String data = "";
  var dataset = [];

  void processData(var data, var splitValue) {
    RegExp frames = new RegExp(".{1," + splitValue.toStringAsFixed(0) + "}");
    String str = base64.encode(utf8.encode(data));
    Iterable<Match> matches = frames.allMatches(str);
    var list = matches.map((m) => m.group(0)).toList();
    widget.stdMsgData = [];
    for (var i = 0; i < list.length; i++) {
      var pageCount = i + 1;
      var framesData = {
        "max": "${list.length}",
        "page": pageCount,
        "data": list[i]
      };
      var jsonFrame = jsonEncode(framesData);

      setState(() {
        widget.stdMsgData.add(jsonFrame);
      });
    }
    //print("${widget.stdMsgData}");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var qrData = widget.sortedJson;
    webcamQRData = [];
    processData(qrData, 100);
    loadedData = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: AlertDialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Builder(
            builder: (context) {
              // Get available height and width of the build area of this widget. Make a choice depending on the size.
              //var height = MediaQuery.of(context).size.height;
              //var width = MediaQuery.of(context).size.width;

              return Container(
                  width: 400,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                            color: Colors.purple[900],
                            child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Transaction Confirmation",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      color: Colors.white,
                                      child: SizedBox(
                                          width: 400,
                                          child: Padding(
                                              padding: const EdgeInsets.all(30.0),
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                                if (stepper == 0) ...[
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.all(2),
                                                            decoration: new BoxDecoration(
                                                              color: KiraColors.kPurpleColor,
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(1000),
                                                              child: CircleAvatar(
                                                                backgroundColor: Colors.white,
                                                                child: SvgPicture.string(
                                                                  Jdenticon.toSvg(widget.message.fromAddress),
                                                                  fit: BoxFit.contain,
                                                                  height: 70,
                                                                  width: 70,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Text("-" + widget.message.amount[0].amount + " ${widget.message.amount[0].denom}")
                                                        ],
                                                      ),
                                                      Container(
                                                          color: Colors.grey[100],
                                                          padding: EdgeInsets.all(20.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text("FROM"),
                                                              Text(widget.message.fromAddress)
                                                            ],
                                                          )),
                                                      Icon(Icons.arrow_downward),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.all(2),
                                                            decoration: new BoxDecoration(
                                                              color: KiraColors.kPurpleColor,
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(1000),
                                                              child: CircleAvatar(
                                                                backgroundColor: Colors.white,
                                                                child: SvgPicture.string(
                                                                  Jdenticon.toSvg(widget.message.toAddress),
                                                                  fit: BoxFit.contain,
                                                                  height: 70,
                                                                  width: 70,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Text("+" + widget.message.amount[0].amount + " ${widget.message.amount[0].denom}")
                                                        ],
                                                      ),
                                                      Container(
                                                          color: Colors.grey[100],
                                                          padding: EdgeInsets.all(20.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text("TO"),
                                                              Text(widget.message.toAddress),
                                                              Divider(),
                                                              Text("Memo:"),
                                                              Text(widget.stdTx.stdMsg.memo)
                                                            ],
                                                          )),
                                                      TextButton(
                                                        onPressed: () {
                                                          showAlertDialog(BuildContext context) {
                                                            /*
                                                            // set up the buttons
                                                            Widget cancelButton = TextButton(
                                                              child: Text("Cancel"),
                                                              onPressed: () {},
                                                            );
                                                            Widget continueButton = TextButton(
                                                              child: Text("Continue"),
                                                              onPressed: () {},
                                                            );
*/
                                                            // set up the AlertDialog
                                                            AlertDialog alert = AlertDialog(
                                                              // title: Text(""),
                                                              content: Container(width: 500, child: Text(widget.stdTx.toString())),
                                                              /*
                                                              actions: [
                                                                cancelButton,
                                                                continueButton,
                                                              ],
                                                              */
                                                            );

                                                            // show the dialog
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return Container(width: 400, child: alert);
                                                              },
                                                            );
                                                          }

                                                          showAlertDialog(context);
                                                        },
                                                        child: Text(
                                                          "See More:",
                                                          style: TextStyle(
                                                            decoration: TextDecoration.underline,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                if (stepper == 1) ...[
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      Container(
                                                          padding: EdgeInsets.all(10.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                "SAIFU -- Scan the QRCode",
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ],
                                                          )),
                                                      SizedBox(height: 350, width: 400, child: SaifuFastQR(data: widget.stdMsgData)),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "SAIFU -- Sign the QR-Code \n \n The website will now scan the QR-Code using Webcam",
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ],
                                                if (stepper == 2) ...[
                                                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "Show  QRCode to confirm signature and broadcast the transaction",
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(20.0),
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
                                                        child: QrCodeCameraWeb(
                                                          qrCodeCallback: (scanData) async {
                                                            //Navigator.pop(context, scanData);
                                                            //print(scanData);
                                                            if (mounted && percentage != 100) {
                                                              final decoded = jsonDecode(scanData);

                                                              int max = int.parse(decoded['max']);
                                                              //print(max);
                                                              var datasize = int.parse(webcamQRData.toSet().length.toString());
                                                              setState(() {
                                                                //print(scanData);

                                                                percentage = (datasize / max) * 100;
                                                                webcamQRData.add(scanData);
                                                              });
                                                              if (percentage == 100) {
                                                                Navigator.pop(context, webcamQRData.toSet().toList());
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                      Text(
                                                        " If QR has been adjusted, restart this procedure \n",
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      CircularProgressIndicator(),
                                                      Text(
                                                        "${percentage.toStringAsFixed(0)}" + "%",
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ])
                                                  ])
                                                ]
                                              ]))))
                                ])))),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    onPressed: () {
                                      if (mounted)
                                        setState(() {
                                          if (stepper == 0) {
                                            Navigator.pop(context);
                                          } else {
                                            stepper--;
                                          }
                                        });
                                    },
                                    icon: Icon(Icons.close),
                                  )))),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: stepper != 2
                                  ? CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        onPressed: () {
                                          if (mounted)
                                            setState(() {
                                              stepper++;
                                            });
                                        },
                                        icon: Icon(Icons.check),
                                      ))
                                  : Container()))
                    ])
                  ]));
            },
          ),
        ));
  }
}
