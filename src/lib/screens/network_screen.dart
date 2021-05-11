import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/models/export.dart';

class NetworkScreen extends StatefulWidget {
  @override
  _NetworkScreenState createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  NetworkService networkService = NetworkService();
  StatusService statusService = StatusService();
  Timer timer;
  List<Validator> validators = [];
  List<Validator> filteredValidators = [];
  String query = "";
  bool initialFetched = false;

  List<String> favoriteValidators = [];
  int expandedRank = -1;
  int sortIndex = 0;
  bool isAscending = true;
  bool isNetworkHealthy = false;
  StreamController validatorController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    getNodeStatus();

    getValidators(false);
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      getValidators(true);
    });
  }

  void getValidators(bool loadNew) async {
    await networkService.getValidators(loadNew);
    if (networkService.totalCount > networkService.validators.length)
      getValidators(false);
    setState(() {
      favoriteValidators = BlocProvider.of<ValidatorBloc>(context).state.favoriteValidators;
      var temp = networkService.validators;
      temp.forEach((element) {
        element.isFavorite = favoriteValidators.contains(element.address);
      });
      validators.clear();
      validators.addAll(temp);
      filteredValidators.clear();
      filteredValidators.addAll(query.isEmpty ? validators : validators.where((x) =>
        x.moniker.toLowerCase().contains(query) || x.address.toLowerCase().contains(query)));
      validatorController.add(null);
    });
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
                            addHeader(),
                            addTableHeader(),
                            (validators.isNotEmpty && filteredValidators.isEmpty)
                                ? Container(
                                margin: EdgeInsets.only(top: 20, left: 20),
                                child: Text("No validators to show",
                                    style: TextStyle(
                                        color: KiraColors.white, fontSize: 18, fontWeight: FontWeight.bold)))
                                : addValidatorsTable(),
                          ],
                        ),
                      )));
            }));
  }

  Widget addHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child: ResponsiveWidget.isLargeScreen(context)
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          addHeaderTitle(),
          addSearchInput(),
        ],
      )
          : Column(
        children: <Widget>[
          addHeaderTitle(),
          addSearchInput(),
        ],
      ),
    );
  }

  Widget addHeaderTitle() {
    return Row(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(bottom: 50),
            child: Text(
              Strings.validators,
              textAlign: TextAlign.left,
              style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
            )),
        SizedBox(width: 30),
        InkWell(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/blocks');
            },
            child: Icon(Icons.swap_horiz, color: KiraColors.white.withOpacity(0.8))),
        SizedBox(width: 10),
        InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/blocks');
          },
          child: Container(
              child: Text(
                Strings.blocks,
                textAlign: TextAlign.left,
                style: TextStyle(color: KiraColors.white, fontSize: 20, fontWeight: FontWeight.w900),
              )),
        ),
      ],
    );
  }

  Widget addSearchInput() {
    return Container(
      width: 500,
      child: AppTextField(
        hintText: Strings.validatorQuery,
        labelText: Strings.search,
        textInputAction: TextInputAction.search,
        maxLines: 1,
        autocorrect: false,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.left,
        onChanged: (String newText) {
          this.setState(() {
            query = newText.toLowerCase();
            filteredValidators = validators.where((x) =>
              x.moniker.toLowerCase().contains(query) || x.address.toLowerCase().contains(query))
                .toList();
            expandedRank = -1;
            validatorController.add(null);
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
    );
  }

  Widget addTableHeader() {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(right: 40, bottom: 20),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: InkWell(
                  onTap: () => this.setState(() {
                    if (sortIndex == 3)
                      isAscending = !isAscending;
                    else {
                      sortIndex = 3;
                      isAscending = true;
                    }
                    expandedRank = -1;
                    refreshTableSort();
                  }),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sortIndex != 3
                          ? [
                        Text("Status",
                            style: TextStyle(
                                color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      ]
                          : [
                        Text("Status",
                            style: TextStyle(
                                color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 5),
                        Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                      ]))),
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
                    expandedRank = -1;
                    refreshTableSort();
                  }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sortIndex != 0
                        ? [
                      Text("Rank",
                          style:
                          TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    ]
                        : [
                      Text("Rank",
                          style:
                          TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 5),
                      Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                    ],
                  ))),
          Expanded(
              flex: 3,
              child: InkWell(
                  onTap: () => this.setState(() {
                    if (sortIndex == 2)
                      isAscending = !isAscending;
                    else {
                      sortIndex = 2;
                      isAscending = true;
                    }
                    expandedRank = -1;
                    refreshTableSort();
                  }),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sortIndex != 2
                          ? [
                        Text("Moniker",
                            style: TextStyle(
                                color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      ]
                          : [
                        Text("Moniker",
                            style: TextStyle(
                                color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 5),
                        Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                      ]))),
          Expanded(
              flex: ResponsiveWidget.isSmallScreen(context) ? 4 : 9,
              child: Text("Validator Address",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold))),
          Expanded(
              flex: ResponsiveWidget.isSmallScreen(context) ? 3 : 2,
              child: InkWell(
                  onTap: () => this.setState(() {
                    if (sortIndex == 4)
                      isAscending = !isAscending;
                    else {
                      sortIndex = 4;
                      isAscending = true;
                    }
                    expandedRank = -1;
                    refreshTableSort();
                  }),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sortIndex != 4
                          ? [
                        Text("Favorite",
                            style: TextStyle(
                                color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      ]
                          : [
                        Text("Favorite",
                            style: TextStyle(
                                color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 5),
                        Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                      ]))),
        ],
      ),
    );
  }

  Widget addValidatorsTable() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValidatorsTable(
              isFiltering: query.isNotEmpty,
              totalPages: (networkService.totalCount / 5).ceil(),
              totalValidators: validators,
              validators: filteredValidators,
              expandedRank: expandedRank,
              onChangeLikes: (top) {
                var index = validators.indexWhere((element) => element.top == top);
                if (index >= 0) {
                  var currentAccount = BlocProvider.of<AccountBloc>(context).state.currentAccount;
                  BlocProvider.of<ValidatorBloc>(context)
                      .add(ToggleFavoriteAddress(validators[index].address, currentAccount.hexAddress));
                  this.setState(() {
                    validators[index].isFavorite = !validators[index].isFavorite;
                  });
                }
              },
              controller: validatorController,
              onTapRow: (index) => this.setState(() {
                expandedRank = index;
              }),
            ),
          ],
        ));
  }

  refreshTableSort() {
    this.setState(() {
      if (sortIndex == 0) {
        filteredValidators.sort((a, b) => isAscending ? a.top.compareTo(b.top) : b.top.compareTo(a.top));
      } else if (sortIndex == 2) {
        filteredValidators
            .sort((a, b) => isAscending ? a.moniker.compareTo(b.moniker) : b.moniker.compareTo(a.moniker));
      } else if (sortIndex == 3) {
        filteredValidators.sort((a, b) => isAscending ? a.status.compareTo(b.status) : b.status.compareTo(a.status));
      } else if (sortIndex == 4) {
        filteredValidators.sort((a, b) => !isAscending
            ? a.isFavorite.toString().compareTo(b.isFavorite.toString())
            : b.isFavorite.toString().compareTo(a.isFavorite.toString()));
      }
    });
  }
}
