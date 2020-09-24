import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'transaction_result_model.g.dart';

/// Represents the result that is returned when broadcasting a transaction.
@JsonSerializable(explicitToJson: true)
class TransactionResultModel extends Equatable {
  final String code;
  final String data;
  final String log;
  final String codespace;
  final String hash;
  final TransactionError error;

  TransactionResultModel({
    @required this.code,
    @required this.data,
    @required this.log,
    @required this.codespace,
    @required this.hash,
    this.error,
  })  : assert(code != null),
        assert(data != null),
        assert(log != null),
        assert(codespace != null),
        assert(hash != null || error != null);

  @override
  List<Object> get props {
    return [code, data, log, codespace, hash, error];
  }

  factory TransactionResultModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionResultModelToJson(this);
}

/// Contains the data related to an error that has occurred when
/// broadcasting the transaction.
@JsonSerializable(explicitToJson: true)
class TransactionError extends Equatable {
  final int code;
  final String data;
  final String message;

  TransactionError({
    @required this.code,
    @required this.data,
    @required this.message,
  });

  @override
  List<Object> get props {
    return [code, data, message];
  }

  factory TransactionError.fromJson(Map<String, dynamic> json) =>
      _$TransactionErrorFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionErrorToJson(this);
}
