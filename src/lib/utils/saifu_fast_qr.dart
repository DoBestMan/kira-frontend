
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

// ignore: must_be_immutable
class SaifuFastQR extends StatefulWidget {
  // Original data passed through
  var data;
  // {rocessed data split into frames
  var frameData;
  // Specifies how many character frames to split the [data] into [frameData]
  var charPerFrame;
  // This is the duration/speed of the transition from one qr to another (when multiple qr are displayed)
  double transitionDuration;
  final double fade;
  final double scale;
  // Decide for a swiple layout between DEFAULT, STACK, TINDER, and CUSTOM
  final SwiperLayout layout;
  final bool loop;
  final bool enableSlider;
  final bool autoplay;
  final int autoplayDelay;
  final double viewportFraction;

  final Axis scrollDirection;

  final Color boxShadowColor;
  final Offset boxShadowOffset;
  final double boxShadowBlurRadius;
  // QRErrorCorrectLevel.H / M / S, higher levels ensures the qr can be read more correctly and less errors likely [more data is used]
  final int errorCorrectionalLevel;
  // Displays a Error message instead of the qr
  final String qrErrorMessage;
  final double minCharacterSize;
  final double maxCharacterSize;
  // Breaks the slider between the qr, that decides char lengths, into sections
  final int charSliderDivisions;
  final double itemWidth;
  final double itemHeight;

  SaifuFastQR({
    Key key,
    this.charPerFrame: 100,
    this.enableSlider: false,
    @required this.data,
    this.itemHeight = 300,
    this.itemWidth = 300,
    this.frameData,
    this.transitionDuration: 50,
    this.fade,
    this.scale,
    this.layout: SwiperLayout.DEFAULT,
    this.loop: true,
    this.autoplay: true,
    this.autoplayDelay: 0,
    this.viewportFraction: 0.8,
    this.scrollDirection: Axis.horizontal,
    this.boxShadowColor: Colors.grey,
    this.boxShadowOffset: const Offset(0.0, 1.0),
    this.boxShadowBlurRadius: 15,
    this.errorCorrectionalLevel: QrErrorCorrectLevel.H,
    this.qrErrorMessage: "QR code could not be generated",
    this.minCharacterSize: 10,
    this.maxCharacterSize: 1000,
    this.charSliderDivisions: 5,
  }) : super(key: key);

  @override
  _SaifuFastQRState createState() => _SaifuFastQRState();
}

class _SaifuFastQRState extends State<SaifuFastQR> {
  @override
  void initState() {
    //handleQRData();
    //print(widget.data);
    //widget.frameData = jsonEncode(widget.data);
    //print(widget.frameData);
    //handleQRData();
    //print(widget.data);
    //print(widget.stdMsgData);

    //processData(widget.data, 100);
    super.initState();
  }

  void handleQRData() {
    var stringData = '';
    for (int i = 0; i < widget.data.length; i++) {
      stringData = stringData + widget.data[i].toString();
      setState(() {
        widget.frameData = stringData;
      });
    }
    RegExp exp = new RegExp(".{1," + widget.charPerFrame.toStringAsFixed(0) + "}");
    String str = widget.frameData;
    Iterable<Match> matches = exp.allMatches(str);
    var list = matches.map((m) => m.group(0)).toList();
    print(list);

    List<String> stdFrame = [];
    for (var i = 0; i < list.length; i++) {
      var pageCount = i + 1;
      var framesData = {
        "max": "${list.length}",
        "page": pageCount,
        "data": list[i]
      };
      var jsonFrame = jsonEncode(framesData);
      stdFrame.add(jsonFrame);
    }

    print(stdFrame);
    setState(() {
      widget.data = [];
      widget.data = stdFrame;
    });
  }

/*
  void processData(var data, var splitValue) {
    RegExp frames = new RegExp(".{1," + splitValue.toStringAsFixed(0) + "}");

    String str = base64.encode(utf8.encode(data));
    Iterable<Match> matches = frames.allMatches(str);
    var list = matches.map((m) => m.group(0)).toList();
    //widget.stdMsgData = [];
    for (var i = 0; i < list.length; i++) {
      var pageCount = i + 1;
      var framesData = {
        "max": "${list.length}",
        "page": pageCount,
        "data": list[i]
      };
      var jsonFrame = jsonEncode(framesData);

      setState(() {
        widget.stdMsgData.add(jsonFrame);
        widget.frameData = widget.stdMsgData;
      });
    }
    //print("${widget.stdMsgData}");
  }
*/
  @override
  Widget build(BuildContext context) {
    if (widget.data.length > 0) {
      return Column(
        children: [
          Swiper(
            itemHeight: widget.itemHeight,
            itemWidth: widget.itemWidth,
            fade: widget.fade,
            scale: widget.scale,
            loop: widget.loop,
            autoplay: widget.autoplay,
            autoplayDelay: widget.autoplayDelay,
            duration: widget.transitionDuration.toInt(),
            viewportFraction: widget.viewportFraction,
            scrollDirection: widget.scrollDirection,
            itemCount: widget.data.length,
            layout: SwiperLayout.CUSTOM,
            customLayoutOption: new CustomLayoutOption(startIndex: 0, stateCount: 5).addScale([
              1,
              1,
              1,
              1,
              1,
            ], Alignment.center).addTranslate([
              Offset(0.0, 0.0),
              Offset(0.0, 0.0),
              Offset(0.0, 0.0),
              Offset(0.0, 0.0),
              Offset(0.0, 0.0),
            ]).addOpacity([
              0.0,
              0.0,
              0.0,
              1.0,
              0.0,
            ]),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(12)), boxShadow: [
                        BoxShadow(color: Colors.grey, offset: Offset(0.0, 1.0), blurRadius: 15.0)
                      ]),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: QrImage(
                            data: widget.data[index].toString(),
                            version: QrVersions.auto,
                            errorCorrectionLevel: QrErrorCorrectLevel.L,
                            errorStateBuilder: (cxt, err) {
                              return Container(
                                child: Center(
                                  child: Text(
                                    "QR code could not be generated",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          widget.enableSlider
              ? SizedBox(
                  width: 200,
                  child: Slider(
                    value: widget.charPerFrame,
                    min: widget.minCharacterSize,
                    max: widget.maxCharacterSize,
                    divisions: widget.charSliderDivisions,
                    activeColor: Colors.black,
                    label: '${widget.charPerFrame}',
                    onChanged: (newCharacterSize) {
                      setState(() {
                        widget.charPerFrame = newCharacterSize;
                        //processData(widget.data, newCharacterSize);
                        //handleQRData();
                      });
                    },
                  ))
              : Container()
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          Text('Data provided is not null or empty')
        ],
      );
    }
  }
}
