import 'package:meta/meta.dart';

enum SignMode {
  SIGN_MODE_UNSPECIFIED,
  SIGN_MODE_DIRECT,
  SIGN_MODE_TEXTUAL,
  SIGN_MODE_LEGACY_AMINO_JSON
}

// ignore: todo
// TODO: Here modeInfo should be Mode_Info object
class SignerInfo {
  final String publicKey;
  final String modeInfo; //
  final int sequence;

  const SignerInfo(
      {@required this.publicKey,
      @required this.modeInfo,
      @required this.sequence})
      : assert(publicKey != null),
        assert(modeInfo != null),
        assert(sequence != null);

  factory SignerInfo.fromJson(Map<String, dynamic> json) => SignerInfo(
        publicKey: json['public_key'] as String,
        modeInfo: json['mode_info'] as String,
        sequence: json['sequence'] as int,
      );

  Map<String, dynamic> toJson() => {
        'public_key': this.publicKey,
        'mode_info': this.modeInfo,
        'sequence': this.sequence,
      };
}
