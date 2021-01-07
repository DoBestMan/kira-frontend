import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/styles.dart';

/// A widget for displaying a mnemonic phrase
class MnemonicDisplay extends StatefulWidget {
  final List<String> wordList;
  final bool obscureSeed;
  final bool isCopied;
  final int rowNumber;

  MnemonicDisplay({@required this.wordList, this.obscureSeed = false, this.isCopied = false, this.rowNumber = 6});

  _MnemonicDisplayState createState() => _MnemonicDisplayState();
}

class _MnemonicDisplayState extends State<MnemonicDisplay> {
  // static final List<String> _obscuredSeed = List.filled(24, '•' * 6);

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildMnemonicRows() {
    int nRows = widget.rowNumber;
    int itemsPerRow = 24 ~/ nRows;
    int curWord = 0;
    List<Widget> ret = [];
    for (int i = 0; i < nRows; i++) {
      // Build individual items
      List<Widget> items = [];
      for (int j = 0; j < itemsPerRow; j++) {
        items.add(Expanded(
            child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          height: 32,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 1,
                  color: widget.isCopied
                      ? KiraColors.kYellowColor.withOpacity(0.6)
                      : KiraColors.kGrayColor.withOpacity(0.3)),
              color: KiraColors.kGrayColor.withOpacity(0.0),
              borderRadius: BorderRadius.circular(20.0)),
          child: Center(
              child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(children: [
              TextSpan(
                text: curWord < 9 ? " " : "",
                style: AppStyles.textStyleNumbersOfMnemonic(context),
              ),
              TextSpan(
                text: " ${curWord + 1}. ",
                style: AppStyles.textStyleNumbersOfMnemonic(context),
              ),
              TextSpan(
                text: widget.wordList != null && widget.wordList.length > 0 ? widget.wordList[curWord] : "",
                style: AppStyles.textStyleMnemonic(context),
              )
            ]),
          )),
        )));
        curWord++;
      }
      ret.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: items),
        ),
      );
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: _buildMnemonicRows(),
      ),
    );
  }
}
