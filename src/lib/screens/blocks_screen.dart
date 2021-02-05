import 'dart:async';
import 'dart:math';

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
  List<Block> blocks = [];
  List<Transaction> transactions = [];
  Block filteredBlock;
  Timer timer;
  String hashQuery = "";
  String heightQuery = "";

  bool searchSubmitted = false;
  bool isFiltering = false;
  bool isHashActive = true;
  int expandedHeight = -1;

  final _hashFocusNode = FocusNode();
  final _heightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    getBlocks();
    timer = Timer.periodic(Duration(seconds: 5), (timer) { getBlocks(); });
    _hashFocusNode.addListener(() { this.setState(() { isHashActive = true; }); });
    _heightFocusNode.addListener(() { this.setState(() { isHashActive = false; }); });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void getBlocks() async {
    await networkService.getBlocks();
    if (mounted) {
      setState(() {
        filteredBlock = null;
        blocks.insertAll(0, networkService.blocks);
        blocks.length = min(blocks.length, 10);
      });
    }
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
                constraints: BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    addHeaderTitle(),
                    isFiltering ? addSearchHeader() : addTableHeader(),
                    isFiltering ?
                      filteredBlock == null ? !searchSubmitted ? Container() : Container(
                        margin: EdgeInsets.only(top: 20, left: 20),
                        child: Text("No matching block", style: TextStyle(color: KiraColors.white, fontSize: 18, fontWeight: FontWeight.bold))
                      ) : addBlockInfo()
                      : blocks.isEmpty ? Container(
                        margin: EdgeInsets.only(top: 20, left: 20),
                        child: Text("No matching blocks", style: TextStyle(color: KiraColors.white, fontSize: 18, fontWeight: FontWeight.bold))
                      ) : addBlocksTable(),
                  ],
                ),
              )
            )
          );
        })
    );
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
                )
              ),
              SizedBox(width: 30),
              InkWell(
                onTap: () { Navigator.pushReplacementNamed(context, '/network'); },
                child: Icon(Icons.swap_horiz, color: KiraColors.white.withOpacity(0.8)),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () { Navigator.pushReplacementNamed(context, '/network'); },
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
            child: InkWell(
              onTap: () { this.setState(() {
                isFiltering = !isFiltering;
                if (isFiltering) timer.cancel();
                else timer = Timer.periodic(Duration(seconds: 5), (timer) { getBlocks(); });
              }); },
              child: Icon(isFiltering ? Icons.close : Icons.search, color: KiraColors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget addTableHeader() {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(right: 65, bottom: 20),
      child: Expanded(
      child: Row(
        children:[
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.access_time, color: KiraColors.white),
                SizedBox(width: 5),
                Text("Time (UTC)", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("# Hash", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.perm_contact_cal, color: KiraColors.white),
                SizedBox(width: 5),
                Text("Proposer", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.sync, color: KiraColors.white),
                SizedBox(width: 5),
                Text("No. of Txs", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.height, color: KiraColors.white),
                SizedBox(width: 5),
                Text("Height", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )
          ),
        ])
      ),
    );
  }

  Widget addSearchHeader() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Expanded(
        child: Row(
          children:[
            Expanded(
              flex: isHashActive ? 10 : 1,
              child: AppTextField(
                hintText: Strings.block_hash_query,
                textInputAction: TextInputAction.search,
                maxLines: 1,
                autocorrect: false,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.left,
                onChanged: (String newText) {
                  this.setState(() {
                    hashQuery = newText;
                    searchSubmitted = false;
                  });
                },
                focusNode: _hashFocusNode,
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
            SizedBox(width: 40),
            Expanded(
              flex: isHashActive ? 1 : 10,
              child: AppTextField(
                hintText: Strings.block_height_query,
                textInputAction: TextInputAction.search,
                maxLines: 1,
                autocorrect: false,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.left,
                onChanged: (String newText) {
                  this.setState(() {
                    heightQuery = newText;
                    searchSubmitted = false;
                  });
                },
                focusNode: _heightFocusNode,
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
                  if ((isHashActive ? hashQuery : heightQuery).trim().isEmpty) {
                    AlertDialog alert = AlertDialog(title: Text(Strings.kiraNetwork), content: Text(Strings.no_keyword_input));

                    showDialog(context: context, builder: (BuildContext context) { return alert; });
                    return;
                  }
                  networkService.searchBlock((isHashActive ? hashQuery : heightQuery), isHashActive).then((v) {
                    this.setState(() {
                      filteredBlock = networkService.block;
                      searchSubmitted = true;
                    });
                  });
                },
                child: Icon(Icons.search, color: KiraColors.white, size: 24),
              ),
            ),
          ]
        )
      ),
    );
  }

  Widget addBlocksTable() {
    return Container(
      margin: EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocksTable(
            blocks: blocks,
            expandedHeight: expandedHeight,
            transactions: transactions,
            onTapRow: (height) => {
              if (height == -1) this.setState(() {
                expandedHeight = height;
                transactions.clear();
              })
              else networkService.getTransactions(height).then((v) => {
                this.setState(() {
                  expandedHeight = height;
                  transactions.clear();
                  transactions.addAll(networkService.transactions);
                })
              })
            }
          ),
        ],
      ));
  }

  Widget addBlockInfo() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 2,
              child: Text(filteredBlock.getTimeString(), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          ),
          SizedBox(width: 10),
          Expanded(
              flex: 1,
              child: Text("0x"+ filteredBlock.appHash, overflow: TextOverflow.ellipsis, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          ),
          SizedBox(width: 10),
          Expanded(
              flex: 2,
              child: Text("0x"+ filteredBlock.proposerAddress, overflow: TextOverflow.ellipsis, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          ),
          SizedBox(width: 10),
          Expanded(
              flex: 1,
              child: Text(filteredBlock.txAmount.toString(), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          ),
          SizedBox(width: 10),
          Expanded(
              flex: 1,
              child: Text(filteredBlock.getHeightString(), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          )],
      ),
    );
  }
}
