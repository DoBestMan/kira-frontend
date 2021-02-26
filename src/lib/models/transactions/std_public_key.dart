import 'package:meta/meta.dart';
import 'dart:convert';

class StdPublicKey {
  final String type;
  final String key;

  const StdPublicKey({@required this.type, @required this.key})
      : assert(type != null),
        assert(key != null);

  factory StdPublicKey.fromJson(Map<String, dynamic> json) => StdPublicKey(type: json['@type'], key: json['key']);

  Map<String, dynamic> toJson() => {'@type': this.type, 'key': this.key};

  String toString() => jsonEncode(toJson());
}
