import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/styles.dart';
import 'package:kira_auth/utils/responsive.dart';

/// A widget for displaying a mnemonic phrase
class MnemonicDisplay extends StatefulWidget {
  final List<String> wordList;
  final bool obscureSeed;
  final bool showButton;

  MnemonicDisplay(
      {@required this.wordList,
      this.obscureSeed = false,
      this.showButton = true});

  _MnemonicDisplayState createState() => _MnemonicDisplayState();
}

class _MnemonicDisplayState extends State<MnemonicDisplay> {
  // static final List<String> _obscuredSeed = List.filled(24, '•' * 6);
  // bool _seedObscured;
  bool _seedCopied;

  @override
  void initState() {
    super.initState();

    _seedCopied = false;
    // _seedObscured = true;
  }

  List<Widget> _buildMnemonicRows() {
    int nRows = 6;
    int itemsPerRow = 24 ~/ nRows;
    int curWord = 0;
    List<Widget> ret = [];
    for (int i = 0; i < nRows; i++) {
      ret.add(Container(
        width: (MediaQuery.of(context).size.width *
            (ResponsiveWidget.isSmallScreen(context) ? 0.7 : 0.8)),
        height: 1.5,
        color: KiraColors.kPurpleColor,
      ));
      // Build individual items
      List<Widget> items = [];
      for (int j = 0; j < itemsPerRow; j++) {
        items.add(
          Container(
            width: (MediaQuery.of(context).size.width *
                    (ResponsiveWidget.isSmallScreen(context) ? 0.7 : 0.4)) /
                itemsPerRow,
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(children: [
                TextSpan(
                  text: curWord < 9 ? " " : "",
                  style: AppStyles.textStyleNumbersOfMnemonic(context),
                ),
                TextSpan(
                  text: " ${curWord + 1}) ",
                  style: AppStyles.textStyleNumbersOfMnemonic(context),
                ),
                TextSpan(
                  text: widget.wordList != null ? widget.wordList[curWord] : "",
                  style: _seedCopied
                      ? AppStyles.textStyleMnemonicSuccess(context)
                      : AppStyles.textStyleMnemonic(context),
                )
              ]),
            ),
          ),
        );
        curWord++;
      }
      ret.add(
        Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Container(
              margin: EdgeInsetsDirectional.only(start: 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, children: items),
            )),
      );
      if (curWord == itemsPerRow * nRows) {
        ret.add(Container(
          width: (MediaQuery.of(context).size.width *
              (ResponsiveWidget.isSmallScreen(context) ? 0.7 : 0.8)),
          height: 1.5,
          color: KiraColors.kPurpleColor,
        ));
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        children: _buildMnemonicRows(),
      ),
    );
  }
}
