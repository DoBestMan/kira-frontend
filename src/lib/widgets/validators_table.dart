import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/validator.dart';
import 'package:kira_auth/utils/colors.dart';

class ValidatorsTable extends StatefulWidget {
  final List<Validator> validators;
  final Function onChangeLikes;
  final int sortIndex;
  final bool isAscending;

  ValidatorsTable({
    Key key,
    this.validators,
    this.onChangeLikes,
    this.sortIndex,
    this.isAscending,
  }) : super();

  @override
  _ValidatorsTableState createState() => _ValidatorsTableState();
}

class _ValidatorsTableState extends State<ValidatorsTable> {
  int expandedIndex;

  @override
  void initState() {
    super.initState();
    expandedIndex = -1;
  }

  @override
  void dispose() {
    super.dispose();
  }

  onSortColumn(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        widget.validators.sort((a, b) => a.rank.compareTo(b.rank));
      } else {
        widget.validators.sort((a, b) => b.rank.compareTo(a.rank));
      }
    } else if (columnIndex == 2) {
      if (ascending) {
        widget.validators.sort((a, b) => a.moniker.compareTo(b.moniker));
      } else {
        widget.validators.sort((a, b) => b.moniker.compareTo(a.moniker));
      }
    } else if (columnIndex == 3) {
      if (ascending) {
        widget.validators.sort((a, b) => a.status.compareTo(b.status));
      } else {
        widget.validators.sort((a, b) => b.status.compareTo(a.status));
      }
    } else if (columnIndex == 4) {
      if (ascending) {
        widget.validators.sort((a, b) => a.isLiked.toString().compareTo(b.isLiked.toString()));
      } else {
        widget.validators.sort((a, b) => b.isLiked.toString().compareTo(a.isLiked.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: widget.validators.isNotEmpty ?
          ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) => setState(() { expandedIndex = !isExpanded ? index : -1; }),
            children: widget.validators.asMap().map((index, validator) => MapEntry(index, ExpansionPanel(
              backgroundColor: KiraColors.transparent,
              headerBuilder: (BuildContext bctx, bool isExpanded) => addRowHeader(validator, isExpanded),
              body: addRowBody(validator),
              isExpanded: expandedIndex == index,
              canTapOnHeader: true,
            ))).values.toList(),
          ) :
          Text("No matching validators", style: TextStyle(color: KiraColors.white, fontSize: 18, fontWeight: FontWeight.bold))
      ));
  }

  Widget addRowHeader(Validator validator, bool isExpanded) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 2,
            child: Text("${validator.rank + 1}.",
              textAlign: TextAlign.center,
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
            )
          ),
          Expanded(
            flex: 9,
            child: Text(validator.address,
              textAlign: TextAlign.center,
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
            )
          ),
          Expanded(
            flex: 3,
            child: Text(validator.moniker,
              textAlign: TextAlign.center,
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)
            )
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(
                  color: validator.getColor().withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(Icons.circle, size: 12.0, color: validator.getColor()),
                ),
              ))
          ),
          Expanded(
            flex: 2,
            child: IconButton(
              icon: Icon(validator.isLiked ? Icons.favorite : Icons.favorite_border, color: KiraColors.blue1),
              color: validator.isLiked ? KiraColors.kYellowColor2 : KiraColors.white,
              onPressed: () => widget.onChangeLikes(validator.rank))
          )],
        ),
      );
  }

  Widget addRowBody(Validator validator) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Validator Key",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(validator.valkey, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Public Key",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(validator.pubkey, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Website",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(validator.website ?? "Unknown", style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Social",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(validator.social, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Identity",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(validator.identity, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Commission",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Container(
                  width: 200,
                  height: 30,
                  decoration: new BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: new Border.all(color: KiraColors.green3, width: 1),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: Container(
                      width: 194 * validator.commission,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: KiraColors.green2,
                      )
                    )
                  )
                ),
              )
            ],
          ),
          SizedBox(height: 10),
        ]
      ));
  }
}
