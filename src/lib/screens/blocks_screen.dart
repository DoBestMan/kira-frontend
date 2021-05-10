import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/models/export.dart';

class BlocksScreen extends StatefulWidget {
  @override
  _BlocksScreenState createState() => _BlocksScreenState();
}

class _BlocksScreenState extends State<BlocksScreen> {
  NetworkService networkService = NetworkService();
  StatusService statusService = StatusService();

  List<Block> blocks = [];
  Block filteredBlock;
  BlockTransaction filteredTransaction;
  List<BlockTransaction> transactions = [];
  List<BlockTransaction> filteredTransactions = [];
  Timer timer;
  String query = "";
  bool initialFetched = false;

  bool isNetworkHealthy = false;
  bool searchSubmitted = false;
  bool isFiltering = false;
  int expandedHeight = -1;
  StreamController blockController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();

    getNodeStatus();
    getBlocks(false);
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      getBlocks(true);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        if (statusService.nodeInfo != null && statusService.nodeInfo.network.isNotEmpty) {
          isNetworkHealthy = statusService.isNetworkHealthy;
          BlocProvider.of<NetworkBloc>(context)
              .add(SetNetworkInfo(statusService.nodeInfo.network, statusService.rpcUrl));
        } else {
          isNetworkHealthy = false;
        }
      });
    }
  }

  void getBlocks(bool loadNew) async {
    await networkService.getBlocks(loadNew);
    if (networkService.latestBlockHeight > networkService.blocks.length)
      getBlocks(false);
    setState(() {
      initialFetched = true;
      blocks.clear();
      blocks.addAll(networkService.blocks);
      blockController.add(null);
    });
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
                        constraints: BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            addHeaderTitle(),
                            isFiltering ? addSearchHeader() : addTableHeader(),
                            isFiltering
                                ? (filteredBlock == null && filteredTransaction == null)
                                ? !searchSubmitted
                                ? Container()
                                : Container(
                                margin: EdgeInsets.only(top: 20, left: 20),
                                child: Text("No matching block or transaction",
                                    style: TextStyle(
                                        color: KiraColors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)))
                                : filteredBlock != null
                                ? addBlockInfo()
                                : addTransactionInfo()
                                : !initialFetched ? addLoadingIndicator() : blocks.isEmpty
                                ? Container(
                                margin: EdgeInsets.only(top: 20, left: 20),
                                child: Text("No blocks to show",
                                    style: TextStyle(
                                        color: KiraColors.white, fontSize: 18, fontWeight: FontWeight.bold)))
                                : addBlocksTable()
                          ],
                        ),
                      )));
            }));
  }

  Widget addLoadingIndicator() {
    return Container(
        alignment: Alignment.center,
        child: Container(
          width: 20,
          height: 20,
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          padding: EdgeInsets.all(0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ));
  }

  Widget addHeaderTitle() {
    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(bottom: 50),
                  child: Text(
                    Strings.blocks,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
                  )),
              SizedBox(width: 30),
              InkWell(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/network');
                },
                child: Icon(Icons.swap_horiz, color: KiraColors.white.withOpacity(0.8)),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/network');
                },
                child: Container(
                  child: Text(
                    Strings.validators,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: KiraColors.white, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(right: 20),
            child: isFiltering
                ? InkWell(
                onTap: () {
                  this.setState(() {
                    isFiltering = false;
                    expandedHeight = -1;
                    transactions.clear();
                  });
                },
                child: Icon(Icons.close, color: KiraColors.white, size: 30))
                : Tooltip(
              message: Strings.blockTransactionQuery,
              waitDuration: Duration(milliseconds: 500),
              decoration: BoxDecoration(color: KiraColors.purple1, borderRadius: BorderRadius.circular(4)),
              verticalOffset: 20,
              preferBelow: ResponsiveWidget.isSmallScreen(context),
              margin: EdgeInsets.only(
                  right: ResponsiveWidget.isSmallScreen(context)
                      ? 20
                      : ResponsiveWidget.isMediumScreen(context)
                      ? 50
                      : 110),
              textStyle: TextStyle(color: KiraColors.white.withOpacity(0.8)),
              child: InkWell(
                onTap: () {
                  this.setState(() {
                    isFiltering = true;
                    expandedHeight = -1;
                    transactions.clear();
                  });
                },
                child: Icon(Icons.search, color: KiraColors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget addTableHeader() {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(right: 40, bottom: 20),
      child: Row(children: [
        Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.height, color: KiraColors.white),
                SizedBox(width: 5),
                Text(ResponsiveWidget.isSmallScreen(context) ? "" : "Height",
                    style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )),
        SizedBox(width: 10),
        Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.perm_contact_cal, color: KiraColors.white),
                SizedBox(width: 5),
                Text("Proposer",
                    style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )),
        SizedBox(width: 10),
        Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.sync, color: KiraColors.white),
                SizedBox(width: 5),
                Text(ResponsiveWidget.isSmallScreen(context) ? "" : "No. of Txs",
                    style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )),
        SizedBox(width: 10),
        Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.access_time, color: KiraColors.white),
                SizedBox(width: 5),
                Text(ResponsiveWidget.isSmallScreen(context) ? "" : "Time",
                    style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )),
      ]),
    );
  }

  Widget addSearchHeader() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(children: [
        Expanded(
          flex: 1,
          child: AppTextField(
            labelText: Strings.blockTransactionQuery,
            textInputAction: TextInputAction.search,
            maxLines: 1,
            autocorrect: false,
            textAlign: TextAlign.left,
            onChanged: (String newText) {
              this.setState(() {
                query = newText.trim();
                searchSubmitted = false;
              });
            },
            padding: EdgeInsets.only(bottom: 15),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
              color: KiraColors.white,
              fontFamily: 'NunitoSans',
            ),
            topMargin: 10,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 50),
          child: InkWell(
              onTap: () {
                if (query.trim().isEmpty) {
                  AlertDialog alert =
                  AlertDialog(title: Text(Strings.kiraNetwork), content: Text(Strings.noKeywordInput));
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      });
                  return;
                }
                networkService.searchBlock(query).then((v) {
                  this.setState(() {
                    filteredTransactions.clear();
                    filteredTransactions.addAll(networkService.transactions);
                    filteredBlock = networkService.block;
                    filteredTransaction = null;
                    searchSubmitted = true;
                  });
                }).catchError((e) => {
                  networkService.searchTransaction(query).then((v) {
                    this.setState(() {
                      filteredTransactions.clear();
                      filteredBlock = null;
                      filteredTransaction = networkService.transaction;
                      searchSubmitted = true;
                    });
                  })
                });
              },
              child: Text(Strings.search, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))),
        ),
      ]),
    );
  }

  Widget addBlocksTable() {
    // blockController = StreamController();

    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocksTable(
              totalPages: (networkService.latestBlockHeight / 5).ceil(),
              blocks: blocks,
              expandedHeight: expandedHeight,
              transactions: transactions,
              onTapRow: (height) => {
                if (height == -1)
                  this.setState(() {
                    expandedHeight = height;
                    transactions.clear();
                  })
                else
                  networkService.getTransactions(height).then((v) => {
                    this.setState(() {
                      expandedHeight = height;
                      transactions.clear();
                      transactions.addAll(networkService.transactions);
                    })
                  })
              },
              controller: blockController,
            ),
          ],
        ));
  }

  Widget addBlockInfo() {
    final fieldWidth = ResponsiveWidget.isSmallScreen(context) ? 80.0 : 150.0;
    return Container(
      margin: EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Card(
              color: KiraColors.purple1.withOpacity(0.2),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text("Block Details",
                        style: TextStyle(color: KiraColors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Container(
                          width: fieldWidth,
                          child: Text("Height",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 20),
                        Text(filteredBlock.getHeightString(),
                            style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: fieldWidth,
                          child: Text("Hash",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 20),
                        Flexible(
                            child: InkWell(
                                onTap: () {
                                  copyText(filteredBlock.getHash);
                                  showToast(Strings.blockHashCopied);
                                },
                                child: Text(filteredBlock.getHash,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))
                            ))
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: fieldWidth,
                          child: Text("Proposer",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 20),
                        Container(
                            padding: EdgeInsets.all(5),
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: new Border.all(
                                color: KiraColors.kPurpleColor,
                                width: 3,
                              ),
                            ),
                            child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Container())),
                        SizedBox(width: 10),
                        Text(
                          filteredBlock.getProposer,
                          style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: fieldWidth,
                          child: Text("No. of Txs",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 20),
                        Text(
                          filteredBlock.txAmount.toString(),
                          style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: fieldWidth,
                          child: Text("Time",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 20),
                        Flexible(
                            child: Text(
                              "${filteredBlock.getLongTimeString()} (${filteredBlock.getTimeString()})",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14),
                            ))
                      ],
                    ),
                  ],
                ),
              )),
          SizedBox(height: 20),
          Text("${filteredTransactions.isEmpty ? "No t" : "T"}ransactions",
              style: TextStyle(
                  color: KiraColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: filteredTransactions.isEmpty ? 20 : 24)),
          SizedBox(height: 20),
          filteredTransactions.isEmpty ? Container() : addTransactionHeader(),
          ...filteredTransactions.map((tx) => addTransactionRow(tx)).toList()
        ],
      ),
    );
  }

  Widget addTransactionInfo() {
    return Container(
      margin: EdgeInsets.only(top: 50),
      child: Column(
        children: [
          addTransactionHeader(),
          addTransactionRow(filteredTransaction),
        ],
      ),
    );
  }

  Widget addTransactionHeader() {
    return Container(
        padding: EdgeInsets.only(bottom: 10),
        margin: EdgeInsets.only(left: ResponsiveWidget.isSmallScreen(context) ? 50 : 100, right: 20),
        child: Row(children: [
          Expanded(
              flex: 1,
              child: Text("Tx Hash",
                  style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold))),
          SizedBox(width: 10),
          Expanded(
              flex: ResponsiveWidget.isSmallScreen(context) ? 2 : 4,
              child: Text("Type",
                  style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold))),
          SizedBox(width: 10),
          Expanded(
              flex: 1,
              child: Text("Height",
                  style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end)),
          SizedBox(width: 10),
          Expanded(
              flex: 1,
              child: Text("Time",
                  style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end)),
          SizedBox(width: 10),
          Expanded(
              flex: 1,
              child: Text("Status",
                  style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center))
        ]));
  }

  Widget addTransactionRow(BlockTransaction transaction) {
    return Card(
        color: KiraColors.green2.withOpacity(0.2),
        child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(left: ResponsiveWidget.isSmallScreen(context) ? 20 : 100),
            child: Row(children: [
              Expanded(
                  flex: 1,
                  child: Row(children: [
                    InkWell(
                      onTap: () {
                        copyText(transaction.getHash);
                        showToast(Strings.txHashCopied);
                      },
                      child: Icon(Icons.copy, size: 20, color: KiraColors.kPrimaryColor),
                    ),
                    SizedBox(width: 10),
                    Text(transaction.getReducedHash,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
                  ])
              ),
              SizedBox(width: 10),
              Expanded(
                  flex: ResponsiveWidget.isSmallScreen(context) ? 2 : 4,
                  child: Row(
                    children: transaction
                        .getTypes()
                        .map((type) => Container(
                        padding: EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 4),
                        child: Text(type, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)),
                        decoration: BoxDecoration(
                            color: KiraColors.purple1.withOpacity(0.8), borderRadius: BorderRadius.circular(4))))
                        .toList(),
                  )),
              SizedBox(width: 10),
              Expanded(
                  flex: 1,
                  child: Text(transaction.getHeightString(),
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
                      textAlign: TextAlign.end)),
              SizedBox(width: 10),
              Expanded(
                  flex: 1,
                  child: Text(transaction.getTimeString(),
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
                      textAlign: TextAlign.end)),
              SizedBox(width: 10),
              Expanded(
                  flex: 1,
                  child: Container(
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        border: new Border.all(
                          color: transaction.getStatusColor().withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(Icons.circle, size: 12.0, color: transaction.getStatusColor()),
                        ),
                      )))
            ])));
  }
}
