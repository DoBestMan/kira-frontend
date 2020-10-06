import 'package:kira_auth/models/export.dart';
import 'package:meta/meta.dart';

class AuthInfo {
  List<SignerInfo> signerInfos;
  final StdFee stdFee;

  AuthInfo({
    @required this.signerInfos,
    @required this.stdFee,
  }) : assert(stdFee != null);

  factory AuthInfo.fromJson(Map<String, dynamic> json) => AuthInfo(
        signerInfos: (json['signer_infos'] as List)
            ?.map((e) => e == null
                ? null
                : SignerInfo.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        stdFee: StdFee.fromJson(json['std_fee']),
      );

  Map<String, dynamic> toJson() => {
        'signer_infos':
            this.signerInfos.map((signerInfo) => signerInfo.toJson()).toList(),
        'fee': this.stdFee.toJson(),
      };
}
