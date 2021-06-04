import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/export.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BlockTransaction {
  final String hash;
  final String status;
  final int blockHeight;
  final int timestamp;
  final int confirmation;
  final int gasWanted;
  final int gasUsed;
  List<TxSend> transactions;
  List<TxMsg> messages;
  List<StdCoin> fees;

  String get getHash => '0x$hash';
  String get getReducedHash => '0x$hash'.replaceRange(7, hash.length - 3, '....');

  BlockTransaction(
      {this.hash = "",
        this.status = "",
        this.blockHeight = 0,
        this.confirmation = 0,
        this.gasWanted = 0,
        this.gasUsed = 0,
        this.timestamp = 0,
        this.transactions,
        this.messages,
        this.fees}) {
    assert(this.hash != null ||
        this.status != null ||
        this.timestamp != null ||
        this.confirmation != null ||
        this.gasWanted != null ||
        this.gasUsed != null);
  }

  Color getStatusColor() {
    return status == "Success" ? KiraColors.green3 : status == "Pending" ? KiraColors.orange1 : KiraColors.danger;
  }

  List<String> getTypes() {
    return messages.map((msg) => msg.getType).toList();
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

  static BlockTransaction fromJson(Map<String, dynamic> data) {
    return BlockTransaction(
      hash: data['hash'],
      status: data['status'],
      blockHeight: data['block_height'],
      timestamp: data['block_timestamp'],
      confirmation: data['confirmation'],
      gasWanted: data['gas_wanted'],
      gasUsed: data['gas_used'],
      transactions: (data['transactions'] as List<dynamic>).map((e) => TxSend.fromJson(e)).toList(),
      messages: (data['msgs'] as List<dynamic>).map((e) => TxMsg.fromJson(e)).toList(),
      fees: (data['fees'] as List<dynamic>).map((e) => StdCoin.fromJson(e)).toList(),
    );
  }
}
