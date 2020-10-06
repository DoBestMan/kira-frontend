import 'dart:convert';

import 'package:kira_auth/models/export.dart';
import 'package:meta/meta.dart';

enum SignMode {
  SIGN_MODE_UNSPECIFIED,
  SIGN_MODE_DIRECT,
  SIGN_MODE_TEXTUAL,
  SIGN_MODE_LEGACY_AMINO_JSON
}

class Single {
  String mode;

  Single({this.mode}) : assert(mode != null);

  Map<String, dynamic> toJson() => {'mode': mode};

  factory Single.fromJson(Map<String, dynamic> json) {
    return Single(mode: json['mode']);
  }
}

class ModeInfo {
  final Single single;

  ModeInfo({this.single}) : assert(single != null);

  Map<String, dynamic> toJson() => {'single': single.toJson()};

  factory ModeInfo.fromJson(Map<String, dynamic> json) =>
      ModeInfo(single: Single.fromJson(json['single'] as Map<String, dynamic>));

  String toString() => jsonEncode(toJson());
}

// ignore: todo
// TODO: Here modeInfo should be Mode_Info object
class SignerInfo {
  final StdPublicKey publicKey;
  final ModeInfo modeInfo; //
  final String sequence;

  const SignerInfo(
      {@required this.publicKey,
      @required this.modeInfo,
      @required this.sequence})
      : assert(publicKey != null),
        assert(modeInfo != null),
        assert(sequence != null);

  factory SignerInfo.fromJson(Map<String, dynamic> json) => SignerInfo(
        publicKey:
            StdPublicKey.fromJson(json['public_key'] as Map<String, dynamic>),
        modeInfo: ModeInfo.fromJson(json['mode_info'] as Map<String, dynamic>),
        sequence: json['sequence'] as String,
      );

  Map<String, dynamic> toJson() => {
        'public_key': this.publicKey,
        'mode_info': this.modeInfo,
        'sequence': this.sequence,
      };
}
