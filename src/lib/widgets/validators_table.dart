import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/validator.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/export.dart';

class ValidatorsTable extends StatefulWidget {
  final List<Validator> totalValidators;
  final List<Validator> validators;
  final int expandedRank;
  final Function onChangeLikes;
  final Function onTapRow;
  final Function readMore;
  final StreamController controller;
  final int totalPages;

  ValidatorsTable({
    Key key,
    this.totalValidators,
    this.validators,
    this.expandedRank,
    this.onChangeLikes,
    this.onTapRow,
    this.readMore,
    this.controller,
    this.totalPages,
  }) : super();

  @override
  _ValidatorsTableState createState() => _ValidatorsTableState();
}

class _ValidatorsTableState extends State<ValidatorsTable> {
  List<ExpandableController> controllers = List.filled(5, null);
  int page = 1;
  int startAt = 0;
  int endAt;
  int pageCount = 5;
  List<Validator> currentValidators = <Validator>[];

  @override
  void initState() {
    super.initState();

    setupValidators(page);
    widget.controller.stream.listen((page) => setupValidators(page));
  }

  setupValidators(newPage) {
    this.setState(() {
      page = newPage;
      startAt = (newPage - 1) * pageCount;
      endAt = startAt + pageCount;
      currentValidators = widget.validators.sublist(startAt, math.min(endAt, widget.validators.length));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            child: ExpandableTheme(
                data: ExpandableThemeData(
                  iconColor: KiraColors.white,
                  useInkWell: true,
                ),
                child: Column(
                  children: <Widget>[
                    addNavigateControls(),
                    ...currentValidators
                      .map((validator) =>
                      ExpandableNotifier(
                        child: ScrollOnExpand(
                          scrollOnExpand: true,
                          scrollOnCollapse: false,
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            color: KiraColors.kBackgroundColor.withOpacity(0.2),
                            child: ExpandablePanel(
                              theme: ExpandableThemeData(
                                headerAlignment: ExpandablePanelHeaderAlignment.center,
                                tapHeaderToExpand: false,
                                hasIcon: false,
                              ),
                              header: addRowHeader(validator),
                              collapsed: Container(),
                              expanded: addRowBody(validator),
                            ),
                          ),
                        ),
                      )
                  ).toList(),
              ])
            )));
  }

  Widget addNavigateControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          onPressed: page > 1 ? loadPreviousPage : null,
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: page > 1 ? KiraColors.white : KiraColors.kGrayColor.withOpacity(0.2),
          ),
        ),
        Text("$page / ${widget.totalPages}", style: TextStyle(fontSize: 16, color: KiraColors.white, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: page < widget.totalPages ? loadNextPage : null,
          icon: Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: page < widget.totalPages ? KiraColors.white : KiraColors.kGrayColor.withOpacity(0.2)
          ),
        ),
      ],
    );
  }

  loadPreviousPage() {
    if (page > 1) {
      setState(() {
        startAt = startAt - pageCount;
        endAt = page == widget.totalPages
            ? endAt - currentValidators.length
            : endAt - pageCount;
        currentValidators = widget.validators.getRange(startAt, endAt).toList();
        page = page - 1;
      });
      refreshExpandStatus();
    }
  }

  loadNextPage() {
    if (page < widget.totalPages) {
      if (widget.validators.length > page * pageCount) {
        setState(() {
          startAt = startAt + pageCount;
          endAt = widget.validators.length > endAt + pageCount
              ? endAt + pageCount
              : widget.validators.length;
          currentValidators =
              widget.validators.getRange(startAt, endAt).toList();
          page = page + 1;
        });
      } else {
        widget.readMore(widget.totalValidators.length);
      }
      refreshExpandStatus();
    }
  }

  refreshExpandStatus({int newExpandRank = -1}) {
    widget.onTapRow(newExpandRank);
    this.setState(() {
      currentValidators.asMap().forEach((index, validator) {
        controllers[index].expanded = validator.rank == newExpandRank;
      });
    });
  }

  Widget addRowHeader(Validator validator) {
    return Builder(
        builder: (context) {
          var controller = ExpandableController.of(context);
          controllers[currentValidators.indexOf(validator)] = controller;

          return InkWell(
              onTap: () {
                var newExpandRank = validator.rank != widget.expandedRank ? validator.rank : -1;
                refreshExpandStatus(newExpandRank: newExpandRank);
              },
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              border: new Border.all(
                                color: validator.getStatusColor().withOpacity(
                                    0.5),
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              child: Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(Icons.circle, size: 12.0,
                                    color: validator.getStatusColor()),
                              ),
                            ))
                    ),
                    Expanded(
                        flex: ResponsiveWidget.isSmallScreen(context) ? 3 : 2,
                        child: Text(
                          "${validator.top}.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: KiraColors.white.withOpacity(0.8),
                              fontSize: 16),
                        )
                    ),
                    Expanded(
                        flex: 3,
                        child: Align(
                            child: InkWell(
                              onTap: () {
                                copyText(validator.moniker);
                                showToast(Strings.validatorMonikerCopied);
                              },
                              child: Text(
                                  validator.moniker,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: KiraColors.white
                                      .withOpacity(0.8), fontSize: 16)
                              ),
                            )
                        )
                    ),
                    Expanded(
                        flex: ResponsiveWidget.isSmallScreen(context) ? 4 : 9,
                        child: Align(
                            child: InkWell(
                                onTap: () {
                                  copyText(validator.address);
                                  showToast(Strings.validatorAddressCopied);
                                },
                                child: Text(
                                  validator.getReducedAddress,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: KiraColors.white
                                      .withOpacity(0.8), fontSize: 16),
                                )
                            )
                        )
                    ),
                    Expanded(
                        flex: 2,
                        child: IconButton(
                            icon: Icon(
                                validator.isFavorite ? Icons.favorite : Icons
                                    .favorite_border, color: KiraColors.blue1),
                            color: validator.isFavorite ? KiraColors
                                .kYellowColor2 : KiraColors.white,
                            onPressed: () => widget.onChangeLikes(validator.top)
                        )
                    ),
                    ExpandableIcon(
                      theme: const ExpandableThemeData(
                        expandIcon: Icons.arrow_right,
                        collapseIcon: Icons.arrow_drop_down,
                        iconColor: Colors.white,
                        iconSize: 28,
                        iconRotationAngle: math.pi / 2,
                        iconPadding: EdgeInsets.only(right: 5),
                        hasIcon: false,
                      ),
                    ),
                  ],
                ),
              )
          );
        }
    );
  }

  Widget addRowBody(Validator validator) {
    final fieldWidth = ResponsiveWidget.isSmallScreen(context) ? 100.0 : 150.0;
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Row(
            children: [
              Container(
                  width: fieldWidth,
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
                  width: fieldWidth,
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
                  width: fieldWidth,
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
                  width: fieldWidth,
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
                  width: fieldWidth,
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
                  width: fieldWidth,
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
