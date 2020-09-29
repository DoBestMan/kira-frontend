import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Contains the information of a generic Cosmos-based network.
class NetworkInfo extends Equatable {
  final String bech32Hrp; // Bech32 human readable part
  final String lcdUrl; // Url to call when accessing the LCD

  NetworkInfo({
    @required this.bech32Hrp,
    @required this.lcdUrl,
  })  : assert(bech32Hrp != null),
        assert(lcdUrl != null);

  @override
  List<Object> get props {
    return [bech32Hrp, lcdUrl];
  }

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInfo(
      bech32Hrp: json['bech32_hrp'] as String,
      lcdUrl: json['lcd_url'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'bech32_hrp': this.bech32Hrp,
        'lcd_url': this.lcdUrl,
      };
}
