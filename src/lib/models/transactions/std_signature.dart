import 'package:meta/meta.dart';

class StdSignature {
  final String signature;

  const StdSignature({
    @required this.signature,
  }) : assert(signature != null);

  Map<String, dynamic> toJson() => {
        'secp256k1': signature,
      };
}
