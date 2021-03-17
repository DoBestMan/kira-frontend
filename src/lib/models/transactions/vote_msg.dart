import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:kira_auth/models/transactions/export.dart';

class VoteMsg {
  final MsgVote proposal;
  final String memo;
  final String timeoutHeight;
  final List<ExtOption> extensionOptions;
  final List<ExtOption> nonCriticalExtensionOptions;

  VoteMsg({
    @required this.proposal,
    @required this.memo,
    @required this.timeoutHeight,
    @required this.extensionOptions,
    @required this.nonCriticalExtensionOptions,
  })  : assert(proposal != null),
        assert(memo != null),
        assert(timeoutHeight != null),
        assert(extensionOptions != null),
        assert(nonCriticalExtensionOptions != null);

  Map<String, dynamic> toJson() => {
    'proposal': this.proposal.toJson(),
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
    final error = this.proposal.validate();
    if (error != null) {
      throw error;
    }
    return null;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
