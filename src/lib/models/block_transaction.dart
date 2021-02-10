import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

import 'package:kira_auth/utils/colors.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Finance {
  String from;
  String to;
  double amount;
  String denom;
  String type;

  Finance({ this.from, this.to, this.amount = 0, this.denom = "", this.type = "" }) {
    assert(this.amount != null || this.denom != null);
  }

  static List<Finance> getFinancesFromJson(List<dynamic> items) {
    List<Finance> finances = [];
    for (int i = 0; i < items.length; i ++) {
      var item = items[i] as Map<String, dynamic>;
      Finance finance = Finance(
        from: item['from'],
        to: item['to'],
        amount: item['amount'],
        denom: item['denom'],
        type: "Send",
      );
      finances.add(finance);
    }
    if (finances.isEmpty) {
      Finance finance = Finance(
        from: 'kira1nfdzpctaadmehhm5uzf7ajanwddz0xngtcn95m',
        to: 'kira1h9s2k2s9624kdghp5ztcdgnausg77rdj9cyat6',
        amount: 100000,
        denom: 'ukex',
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
  List<Finance> fees;

   BlockTransaction({ this.hash = "", this.status = false, this.blockHeight = 0, this.confirmation = 0,
     this.gasWanted = 0, this.gasUsed = 0, this.timestamp = 0, this.transactions, this.fees }) {
     assert(this.hash != null || this.status != null || this.timestamp != null
       || this.confirmation != null || this.gasWanted != null || this.gasUsed != null);
   }

  Color getStatusColor() { return status ? KiraColors.green3 : KiraColors.danger; }

  List<String> getTypes() { return transactions.map((tx) => tx.type).toList(); }
}
