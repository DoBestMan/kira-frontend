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
  ValidatorService validatorService = ValidatorService();
  List<Validator> validators = [];
  List<Validator> filteredValidators = [];
  int expandedIndex = -1;
  int sortIndex = 0;
  bool isAscending = true;

  void getValidators() async {
    await validatorService.getValidators(includesDummy: true);
    if (mounted) {
      setState(() {
        validators.addAll(validatorService.validators);
        filteredValidators.addAll(validatorService.validators);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getValidators();
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
                    addTableHeader(),
                    (validators.isNotEmpty && filteredValidators.isEmpty) ? Container(
                      margin: EdgeInsets.only(top: 20, left: 20),
                      child: Text("No matching validators",
                        style: TextStyle(color: KiraColors.white, fontSize: 18, fontWeight: FontWeight.bold)
                      )
                    ) : addValidatorsTable(context),
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
          Container(
            margin: EdgeInsets.only(bottom: 50),
            child: Text(
              Strings.validators,
              textAlign: TextAlign.left,
              style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
            )
          ),
          Container(
            width: 500,
            child: AppTextField(
              hintText: Strings.validator_query,
              labelText: Strings.search,
              textInputAction: TextInputAction.search,
              maxLines: 1,
              autocorrect: false,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              onChanged: (String newText) {
                this.setState(() {
                  filteredValidators = validators.where((x) => x.moniker.toLowerCase().contains(newText.toLowerCase())
                    || x.address.toLowerCase().contains(newText.toLowerCase())).toList();
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
                  children: sortIndex != 0 ? [
                    Text("Rank", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  ] : [
                    Text("Rank", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                  ],
                )
              )
            ),
            Expanded(
              flex: 9,
              child: Text("Validator Address",
                textAlign: TextAlign.center,
                style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)
              )
            ),
            Expanded(
              flex: 3,
              child:  InkWell(
                onTap: () => this.setState(() {
                  if (sortIndex == 2)
                    isAscending = !isAscending;
                  else {
                    sortIndex = 2;
                    isAscending = true;
                  }
                  expandedIndex = -1;
                  refreshTableSort();
                }),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sortIndex != 2 ? [
                    Text("Moniker", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  ] : [
                    Text("Moniker", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                  ]
                )
              )
            ),
            Expanded(
              flex: 2,
              child:  InkWell(
                onTap: () => this.setState(() {
                  if (sortIndex == 3)
                    isAscending = !isAscending;
                  else {
                    sortIndex = 3;
                    isAscending = true;
                  }
                  expandedIndex = -1;
                  refreshTableSort();
                }),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sortIndex != 3 ? [
                    Text("Status", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  ] : [
                    Text("Status", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                  ]
                )
              )
            ),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () => this.setState(() {
                  if (sortIndex == 4)
                    isAscending = !isAscending;
                  else {
                    sortIndex = 4;
                    isAscending = true;
                  }
                  expandedIndex = -1;
                  refreshTableSort();
                }),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sortIndex != 4 ? [
                    Text("Favorite", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  ] : [
                    Text("Favorite", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                  ]
                )
              )
            ),
          ],
        )
      ),
    );
  }

  Widget addValidatorsTable(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValidatorsTable(
            validators: filteredValidators,
            expandedIndex: expandedIndex,
            onChangeLikes: (rank) {
              var index = validators.indexWhere((element) => element.rank == rank);
              if (index >= 0)
                this.setState(() {
                  validators[index].isLiked = !validators[index].isLiked;
                });
            },
            onTapRow: (index) => this.setState(() { expandedIndex = index; }),
          ),
        ],
      ));
  }

  refreshTableSort() {
    this.setState(() {
      if (sortIndex == 0) {
        if (isAscending) {
          filteredValidators.sort((a, b) => a.rank.compareTo(b.rank));
        } else {
          filteredValidators.sort((a, b) => b.rank.compareTo(a.rank));
        }
      } else if (sortIndex == 2) {
        if (isAscending) {
          filteredValidators.sort((a, b) => a.moniker.compareTo(b.moniker));
        } else {
          filteredValidators.sort((a, b) => b.moniker.compareTo(a.moniker));
        }
      } else if (sortIndex == 3) {
        if (isAscending) {
          filteredValidators.sort((a, b) => a.status.compareTo(b.status));
        } else {
          filteredValidators.sort((a, b) => b.status.compareTo(a.status));
        }
      } else if (sortIndex == 4) {
        if (isAscending) {
          filteredValidators.sort((a, b) => b.isLiked.toString().compareTo(a.isLiked.toString()));
        } else {
          filteredValidators.sort((a, b) => a.isLiked.toString().compareTo(b.isLiked.toString()));
        }
      }
    });
  }
}
