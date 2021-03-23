import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:kira_auth/models/transactions/export.dart';

class VoteMsg {
  final List<MsgVote> messages;
  final String memo;
  final String timeoutHeight;
  final List<ExtOption> extensionOptions;
  final List<ExtOption> nonCriticalExtensionOptions;

  VoteMsg({
    @required this.messages,
    @required this.memo,
    @required this.timeoutHeight,
    @required this.extensionOptions,
    @required this.nonCriticalExtensionOptions,
  })  : assert(messages.isNotEmpty),
        assert(memo != null),
        assert(timeoutHeight != null),
        assert(extensionOptions != null),
        assert(nonCriticalExtensionOptions != null);

  Map<String, dynamic> toJson() => {
    'messages': this.messages.map((message) => message.toJson()).toList(),
    'memo': this.memo,
    'timeout_height': this.timeoutHeight,
    'extension_options':
    this.extensionOptions?.map((option) => option.toJson())?.toList(),
    'non_critical_extension_options': this
        .nonCriticalExtensionOptions
        ?.map((option) => option.toJson())
        ?.toList(),
  };

  Exception validate() {
    messages.forEach((msg) {
      final error = msg.validate();
      if (error != null) {
        throw error;
      }
    });
    return null;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
