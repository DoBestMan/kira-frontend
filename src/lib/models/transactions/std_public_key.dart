import 'package:meta/meta.dart';
import 'dart:convert';

class StdPublicKey {
  final String publicKey;

  const StdPublicKey({
    @required this.publicKey,
  }) : assert(publicKey != null);

  factory StdPublicKey.fromJson(Map<String, dynamic> json) =>
      StdPublicKey(publicKey: json['secp256k1']);

  Map<String, dynamic> toJson() => {'secp256k1': publicKey};

  String toString() => jsonEncode(toJson());
}
