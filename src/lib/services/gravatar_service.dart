import 'package:jdenticon_dart/jdenticon_dart.dart';

class GravatarService {
  String getIdenticon(address) {
    return Jdenticon.toSvg(
      address,
      colorSaturation: 0.41,
      grayscaleSaturation: 0.67,
      colorLightnessMinValue: 0.15,
      colorLightnessMaxValue: 0.80,
      grayscaleLightnessMinValue: 0.40,
      grayscaleLightnessMaxValue: 0.71,
      backColor: '#cecb9f28',
    );
  }
}
