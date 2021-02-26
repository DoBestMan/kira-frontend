import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/validator.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/export.dart';

class ValidatorsTable extends StatefulWidget {
  final List<Validator> validators;
  final int expandedIndex;
  final Function onChangeLikes;
  final Function onTapRow;

  ValidatorsTable({
    Key key,
    this.validators,
    this.expandedIndex,
    this.onChangeLikes,
    this.onTapRow,
  }) : super();

  @override
  _ValidatorsTableState createState() => _ValidatorsTableState();
}

class _ValidatorsTableState extends State<ValidatorsTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            child: ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) => setState(() {
                widget.onTapRow(!isExpanded ? index : -1);
              }),
              children: widget.validators
                  .asMap()
                  .map((index, validator) => MapEntry(
                  index,
                  ExpansionPanel(
                    backgroundColor: KiraColors.transparent,
                    headerBuilder: (BuildContext bctx, bool isExpanded) => addRowHeader(validator, isExpanded),
                    body: addRowBody(validator),
                    isExpanded: widget.expandedIndex == index,
                    canTapOnHeader: true,
                  )))
                  .values
                  .toList(),
            )));
  }

  Widget addRowHeader(Validator validator, bool isExpanded) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              flex: 2,
              child: Text(
                "${validator.rank + 1}.",
                textAlign: TextAlign.center,
                style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
              )
          ),
          Expanded(
              flex: 9,
              child: Align(
                  child: InkWell(
                      onTap: () {
                        copyText(validator.address);
                        showToast("Validator address copied");
                      },
                      child: Text(
                        validator.getReducedAddress,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
                      )
                  )
              )
          ),
          Expanded(
              flex: 3,
              child: Align(
                  child: InkWell(
                    onTap: () {
                      copyText(validator.moniker);
                      showToast("Validator moniker copied");
                    },
                    child: Text(
                        validator.moniker,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)
                    ),
                  )
              )
          ),
          Expanded(
              flex: 2,
              child: Container(
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    border: new Border.all(
                      color: validator.getStatusColor().withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.circle, size: 12.0, color: validator.getStatusColor()),
                    ),
                  ))
          ),
          Expanded(
              flex: 2,
              child: IconButton(
                  icon: Icon(validator.isFavorite ? Icons.favorite : Icons.favorite_border, color: KiraColors.blue1),
                  color: validator.isFavorite ? KiraColors.kYellowColor2 : KiraColors.white,
                  onPressed: () => widget.onChangeLikes(validator.rank)
              )
          )
        ],
      ),
    );
  }

  Widget addRowBody(Validator validator) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Row(
            children: [
              Container(
                  width: 150,
                  child: Text(
                      "Validator Key",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Flexible(child: Text(
                  validator.valkey,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: 150,
                  child: Text(
                      "Public Key",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Flexible(child: Text(
                  validator.pubkey,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: 150,
                  child: Text(
                      "Website",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Text(validator.checkUnknownWith("website"), overflow: TextOverflow.ellipsis, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: 150,
                  child: Text(
                      "Social",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Text(validator.checkUnknownWith("social"), overflow: TextOverflow.ellipsis, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: 150,
                  child: Text(
                      "Identity",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Text(validator.checkUnknownWith("identity"), overflow: TextOverflow.ellipsis, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: 150,
                  child: Text(
                      "Commission",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Container(
                  width: 200,
                  height: 30,
                  decoration: new BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: new Border.all(color: validator.getCommissionColor().withOpacity(0.6), width: 1),
                  ),
                  child: Padding(padding: EdgeInsets.all(3), child: Container(margin: EdgeInsets.only(right: 194.0 - 194.0 * validator.commission), height: 24, decoration: BoxDecoration(shape: BoxShape.rectangle, color: validator.getCommissionColor())))),
            ],
          ),
          SizedBox(height: 10),
        ]));
  }
}
