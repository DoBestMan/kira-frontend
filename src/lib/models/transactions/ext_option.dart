import 'package:meta/meta.dart';

// ignore: todo
// TODO: Define ExtOption
class ExtOption {
  final String option;

  const ExtOption({
    @required this.option,
  }) : assert(option != null);

  factory ExtOption.fromJson(Map<String, dynamic> json) => ExtOption(
        option: json['option'] as String,
      );

  Map<String, dynamic> toJson() => {
        'option': this.option,
      };
}
