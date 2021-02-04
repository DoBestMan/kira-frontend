import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  List<Block> filteredBlocks = [];
  Timer timer;
  String query = "";

  int expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (timer) { getBlocks(); });
    getBlocks();
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
        blocks.insertAll(0, networkService.blocks);
        blocks.length = 10;
        filteredBlocks.clear();
        filteredBlocks.addAll(blocks.where((x) => x.height.toString().contains(query) || x.appHash.toLowerCase().contains(query)).toList());
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
                    addTableHeader(),
                    (blocks.isNotEmpty && filteredBlocks.isEmpty) ? Container(
                      margin: EdgeInsets.only(top: 20, left: 20),
                      child: Text("No matching blocks",
                        style: TextStyle(color: KiraColors.white, fontSize: 18, fontWeight: FontWeight.bold)
                      )
                    ) : addBlocksTable(context),
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
            width: 500,
            child: AppTextField(
              hintText: Strings.block_query,
              labelText: Strings.search,
              textInputAction: TextInputAction.search,
              maxLines: 1,
              autocorrect: false,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              onChanged: (String newText) {
                this.setState(() {
                  query = newText.toLowerCase();
                  filteredBlocks = blocks.where((x) => x.height.toString().contains(query) || x.appHash.toLowerCase().contains(query)).toList();
                  expandedIndex = -1;
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
          ],
        )
      ),
    );
  }

  Widget addBlocksTable(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocksTable(
            blocks: filteredBlocks,
            expandedIndex: expandedIndex,
            onTapRow: (index) => this.setState(() { expandedIndex = index; }),
          ),
        ],
      ));
  }
}
