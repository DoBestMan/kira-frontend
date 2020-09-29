import 'package:equatable/equatable.dart';
import 'package:reflectable/reflectable.dart';
import 'package:kira_auth/codec/export.dart';

class Reflector extends Reflectable {
  const Reflector() : super(newInstanceCapability, subtypeQuantifyCapability);
}

const reflector = Reflector();

abstract class StdMsg extends Equatable {
  /// Default empty constructor to allow the existance of the factory method.
  StdMsg();

  /// Allows to serialize this object into a JSON map.
  Map<String, dynamic> asJson();

  /// Validates this message. If something is wrong within it, returns
  /// the exception to be thrown.
  Exception validate();

  /// Factory method that is defined in order to allow proper message
  /// deserialization.
  factory StdMsg.fromJson(Map<String, dynamic> json) {
    return Codec.deserializeMsg(json);
  }

  /// Method that allows any StdMsg implementation to be serialized properly.
  Map<String, dynamic> toJson() {
    return Codec.serializeMsg(this);
  }
}
