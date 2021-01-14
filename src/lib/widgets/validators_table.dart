import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/validator.dart';
import 'package:kira_auth/utils/colors.dart';

class ValidatorsTable extends StatefulWidget {
  final List<Validator> validators;
  ValidatorsTable({
    Key key,
    this.validators,
  }) : super();

  @override
  _ValidatorsTableState createState() => _ValidatorsTableState();
}

class _ValidatorsTableState extends State<ValidatorsTable> {
  bool sort;

  @override
  void initState() {
    super.initState();
    sort = false;
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
    } else if (columnIndex == 1) {
      if (ascending) {
        widget.validators.sort((a, b) => a.address.compareTo(b.address));
      } else {
        widget.validators.sort((a, b) => b.address.compareTo(a.address));
      }
    } else if (columnIndex == 3) {
      if (ascending) {
        widget.validators.sort((a, b) => a.status.compareTo(b.status));
      } else {
        widget.validators.sort((a, b) => b.status.compareTo(a.status));
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
            sortAscending: sort,
            sortColumnIndex: 0,
            dataRowHeight: 70,
            columns: [
              DataColumn(
                  label: Flexible(
                    child: Text("Rank", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
                  ),
                  numeric: false,
                  tooltip: "Rank",
                  onSort: (columnIndex, ascending) {
                    if (mounted) {
                      setState(() {
                        sort = !sort;
                      });
                      onSortColumn(columnIndex, sort);
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
                        sort = !sort;
                      });
                      onSortColumn(columnIndex, sort);
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
                      sort = !sort;
                    });
                    onSortColumn(columnIndex, sort);
                  }
                }),
            ],
            rows: widget.validators
                .map(
                  (validator) => DataRow(
                  color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    // All rows will have the same selected color.
                    if (states.contains(MaterialState.selected)) return KiraColors.kYellowColor1.withOpacity(0.3);
                    // Even rows will have a grey color.
                    return KiraColors.white.withOpacity(0.05);
                  }),
                  cells: [
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
                  ]),
            )
                .toList(),
          ),
        ));
  }
}
