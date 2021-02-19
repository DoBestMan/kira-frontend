import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:kira_auth/utils/colors.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FinanceAmount {
  double amount;
  String denom;

  FinanceAmount({this.amount = 0, this.denom = ""}) {
    assert(this.amount != null || this.denom != null);
  }

  static List<FinanceAmount> parse(List<dynamic> items) {
    if (items == null) return [];
    List<FinanceAmount> amounts = [];
    for (int i = 0; i < items.length; i++) {
      var item = items[i] as Map<String, dynamic>;
      FinanceAmount amount = FinanceAmount(amount: item['amount'], denom: item['denom']);
      amounts.add(amount);
    }
    return amounts;
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Finance {
  String from;
  String to;
  List<FinanceAmount> amounts;
  String type;

  Finance({this.from, this.to, this.amounts, this.type = ""}) {
    assert(this.type != null);
  }

  static List<Finance> parse(List<dynamic> items) {
    if (items == null) return [];
    List<Finance> finances = [];
    for (int i = 0; i < items.length; i++) {
      var item = items[i] as Map<String, dynamic>;
      Finance finance = Finance(
        from: item['from'],
        to: item['to'],
        amounts: FinanceAmount.parse(item['amounts']),
        type: "Send",
      );
      finances.add(finance);
    }
    if (finances.isEmpty) {
      Finance finance = Finance(
        from: 'kira1nfdzpctaadmehhm5uzf7ajanwddz0xngtcn95m',
        to: 'kira1h9s2k2s9624kdghp5ztcdgnausg77rdj9cyat6',
        amounts: [FinanceAmount(amount: 100000, denom: 'ukex')],
        type: "Delegate",
      );
      finances.add(finance);
    }
    return finances;
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BlockTransaction {
  final String hash;
  final bool status;
  final int blockHeight;
  final int timestamp;
  final int confirmation;
  final int gasWanted;
  final int gasUsed;
  List<Finance> transactions;
  List<FinanceAmount> fees;

  String get getHash => '0x$hash';
  String get getReducedHash => '0x$hash'.replaceRange(7, hash.length - 3, '....');

  BlockTransaction(
      {this.hash = "",
      this.status = false,
      this.blockHeight = 0,
      this.confirmation = 0,
      this.gasWanted = 0,
      this.gasUsed = 0,
      this.timestamp = 0,
      this.transactions,
      this.fees}) {
    assert(this.hash != null ||
        this.status != null ||
        this.timestamp != null ||
        this.confirmation != null ||
        this.gasWanted != null ||
        this.gasUsed != null);
  }

  Color getStatusColor() {
    return status ? KiraColors.green3 : KiraColors.danger;
  }

  List<String> getTypes() {
    return transactions.map((tx) => tx.type).toList();
  }

  String getLongTimeString() {
    var formatter = DateFormat("d MMM yyyy, h:mm:ssa 'UTC'");
    return formatter.format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toUtc());
  }

  String getTimeString() {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toUtc().relative(appendIfAfter: 'ago');
  }

  String getHeightString() {
    if (blockHeight > -1000 && blockHeight < 1000) return blockHeight.toString();

    final String digits = blockHeight.abs().toString();
    final StringBuffer result = StringBuffer(blockHeight < 0 ? '-' : '');
    final int maxDigitIndex = digits.length - 1;
    for (int i = 0; i <= maxDigitIndex; i += 1) {
      result.write(digits[i]);
      if (i < maxDigitIndex && (maxDigitIndex - i) % 3 == 0) result.write(',');
    }
    return result.toString();
  }

  static BlockTransaction parse(Map<String, dynamic> data) {
    return BlockTransaction(
      hash: data['hash'],
      status: data['status'].toLowerCase() == 'success',
      blockHeight: data['block_height'],
      timestamp: data['block_timestamp'],
      confirmation: data['confirmation'],
      gasWanted: data['gas_wanted'],
      gasUsed: data['gas_used'],
      transactions: Finance.parse(data['transactions']),
      fees: FinanceAmount.parse(data['fees']),
    );
  }
}
