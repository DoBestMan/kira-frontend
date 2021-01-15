import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/validator.dart';
import 'package:kira_auth/utils/colors.dart';

class ValidatorsTable extends StatefulWidget {
  final List<Validator> validators;
  final Function onChangeLikes;
  ValidatorsTable({
    Key key,
    this.validators,
    this.onChangeLikes,
  }) : super();

  @override
  _ValidatorsTableState createState() => _ValidatorsTableState();
}

class _ValidatorsTableState extends State<ValidatorsTable> {
  int expandedIndex;
  bool isAscending;
  int sortIndex;

  @override
  void initState() {
    super.initState();
    expandedIndex = -1;
    isAscending = true;
    sortIndex = 1;
  }

  @override
  void dispose() {
    super.dispose();
  }

  onSortColumn(int columnIndex, bool ascending) {
    if (columnIndex == 1) {
      if (ascending) {
        widget.validators.sort((a, b) => a.rank.compareTo(b.rank));
      } else {
        widget.validators.sort((a, b) => b.rank.compareTo(a.rank));
      }
    } else if (columnIndex == 3) {
      if (ascending) {
        widget.validators.sort((a, b) => a.moniker.compareTo(b.moniker));
      } else {
        widget.validators.sort((a, b) => b.moniker.compareTo(a.moniker));
      }
    } else if (columnIndex == 4) {
      if (ascending) {
        widget.validators.sort((a, b) => a.status.compareTo(b.status));
      } else {
        widget.validators.sort((a, b) => b.status.compareTo(a.status));
      }
    } else if (columnIndex == 5) {
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
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 900),
        child: DataTable(
          showCheckboxColumn: false,
          columnSpacing: 20,
          sortAscending: isAscending,
          sortColumnIndex: sortIndex,
          dataRowHeight: 70,
          columns: [
            DataColumn(
              label: Flexible(
                child: Text("No", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
              ),
              numeric: false,
            ),
            DataColumn(
              label: Flexible(
                child: Text("Rank", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
              ),
              numeric: false,
              tooltip: "Rank",
              onSort: (columnIndex, ascending) {
                if (mounted) {
                  setState(() {
                    isAscending = ascending;
                    sortIndex = columnIndex;
                  });
                  onSortColumn(columnIndex, ascending);
                }
              }),
            DataColumn(
              label: Flexible(
                child: Text("Validator Address", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
              ),
              numeric: false,
              tooltip: "Validator Address",
            ),
            DataColumn(
              label: Flexible(
                child: Text("Moniker", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
              ),
              numeric: false,
              tooltip: "Moniker",
              onSort: (columnIndex, ascending) {
                if (mounted) {
                  setState(() {
                    isAscending = ascending;
                    sortIndex = columnIndex;
                  });
                  onSortColumn(columnIndex, ascending);
                }
              }),
            DataColumn(
              label: Flexible(
                child: Text("Status", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
              ),
              numeric: false,
              tooltip: "Status",
              onSort: (columnIndex, ascending) {
                if (mounted) {
                  setState(() {
                    isAscending = ascending;
                    sortIndex = columnIndex;
                  });
                  onSortColumn(columnIndex, ascending);
                }
              }),
            DataColumn(
              label: Flexible(
                child: Text("Favorite", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
              ),
              numeric: false,
              tooltip: "Favorite",
            ),
          ],
          rows: widget.validators.asMap()
            .map((index, validator) => MapEntry(index, addRowView(index, validator))).values.toList(),
        ),
      ));
  }

  DataRow addRowView(int index, Validator validator) {
    return DataRow(
      cells: [
        DataCell(
          Text((index + 1).toString(),
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
        ),
        DataCell(
          Text(validator.rank.toString(),
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
        ),
        DataCell(
          Text(validator.address, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
        ),
        DataCell(
          Text(validator.moniker,
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
        ),
        DataCell(
          Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(
                  color: (validator.status == 'active' ? KiraColors.green3 : KiraColors.orange3).withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.circle,
                    size: 12.0,
                    color: (validator.status == 'active' ? KiraColors.green3 : KiraColors.orange3),
                  ),
                ),
              )),
        ),
        DataCell(
          IconButton(
              icon: Icon(validator.isLiked ? Icons.favorite : Icons.favorite_border, color: KiraColors.blue1),
              color: validator.isLiked ? KiraColors.kYellowColor2 : KiraColors.white,
              onPressed: () {
                widget.onChangeLikes(validator.rank);
              }),
        ),
      ]
    );
  }
}
