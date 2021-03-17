// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import './dotted_border.dart';

class DropzoneWidget extends StatefulWidget {
  final Function handleKeyFile;
  final Function setImported;

  const DropzoneWidget({this.handleKeyFile, this.setImported});

  @override
  _DropzoneWidgetState createState() => new _DropzoneWidgetState();
}

class _DropzoneWidgetState extends State<DropzoneWidget> {
  StreamSubscription<MouseEvent> _onDragOverSubscription;
  StreamSubscription<MouseEvent> _onDropSubscription;
  StreamSubscription<MouseEvent> _onDragLeaveSubscription;
  // StreamSubscription<Event> _fileSelectionSubscription;
  final StreamController<_DragState> _dragStateStreamController = new StreamController<_DragState>.broadcast();
  final StreamController<Point<double>> _pointStreamController = new StreamController<Point<double>>.broadcast();
  //FileUploadInputElement _inputElement;
  File keyFile;
  bool isHover = false;

  /*
  String get _dropZoneText => this._files.isEmpty
    ? 'DropZONE'
    : 'DropZONE\n(${this._files.length})'; //this._files.map<String>((File file) => file.name).join('\n');
  */

  void _onDragOver(MouseEvent value) {
    value.stopPropagation();
    value.preventDefault();
    this._pointStreamController.sink.add(Point<double>(value.layer.x.toDouble(), value.layer.y.toDouble()));
    this._dragStateStreamController.sink.add(_DragState.dragging);
  }

  void _onDrop(MouseEvent value) {
    value.stopPropagation();
    value.preventDefault();
    _pointStreamController.sink.add(null);
    _addFiles(value.dataTransfer.files);
  }

  void _onDragLeave(MouseEvent value) {
    this._dragStateStreamController.sink.add(_DragState.notDragging);
  }

  // void _fileSelection(Event value) {
  //   print(value);
  //   //_addFiles((value.target as FileUploadInputElement).files);
  // }

  void _addFiles(List<File> newFiles) {
    setState(() {
      keyFile = newFiles[0];
    });

    final reader = new FileReader();
    reader.readAsText(keyFile);
    reader.onLoadEnd.listen((e) {
      widget.handleKeyFile(reader.result.toString());
    });
  }

  void openFileExplorer() async {
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.multiple = false;
    uploadInput.draggable = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      setState(() {
        keyFile = files[0];
      });

      final reader = new FileReader();

      reader.readAsText(files[0]);
      reader.onLoadEnd.listen((e) {
        widget.handleKeyFile(reader.result.toString());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    this._onDragOverSubscription = document.body.onDragOver.listen(_onDragOver);
    this._onDropSubscription = document.body.onDrop.listen(_onDrop);
    this._onDragLeaveSubscription = document.body.onDragLeave.listen(_onDragLeave);
    // this._inputElement = FileUploadInputElement(); //..style.display = 'none';
    // this._fileSelectionSubscription = this._inputElement.onChange.listen(_fileSelection);
  }

  @override
  void dispose() {
    this._onDropSubscription.cancel();
    this._onDragOverSubscription.cancel();
    this._onDragLeaveSubscription.cancel();
    // this._fileSelectionSubscription.cancel();
    this._dragStateStreamController.close();
    this._pointStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints boxConstraints) => Stack(
          children: <Widget>[
            InkWell(
              onTap: () {
                openFileExplorer();
              },
              onHover: (value) {
                setState(() {
                  isHover = value ? true : false;
                });
              },
              child: AnimatedContainer(
                curve: Curves.linear,
                duration: Duration(seconds: 1),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: keyFile == null ? KiraColors.kGrayColor.withOpacity(0.1) : KiraColors.purple2.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: DottedBorder(
                    color: isHover ? KiraColors.kYellowColor : KiraColors.white.withOpacity(0.8),
                    strokeWidth: isHover ? 3.0 : 1.0,
                    gap: 10.0,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            Strings.dropFile,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: boxConstraints.maxWidth / 25,
                              color: isHover ? KiraColors.kYellowColor : KiraColors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          if (keyFile != null)
                            Text(
                              keyFile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 15,
                                color: KiraColors.kYellowColor1,
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (keyFile != null)
              Positioned(
                top: 16,
                right: 16,
                width: 50,
                height: 50,
                child: IconButton(
                  alignment: Alignment.center,
                  icon: Icon(
                    Icons.delete_forever_rounded,
                  ),
                  color: KiraColors.white.withOpacity(0.9),
                  iconSize: 40,
                  tooltip: 'Clear',
                  onPressed: () async {
                    //this._inputElement.click();
                    this.setState(() {
                      keyFile = null;
                    });
                    widget.setImported(false);
                  },
                ),
              ),
            StreamBuilder(
              initialData: null,
              stream: this._pointStreamController.stream,
              builder: (BuildContext context, AsyncSnapshot<Point<double>> snapPoint) => (snapPoint.data == null ||
                      snapPoint.data is! Point<double> ||
                      snapPoint.data == const Point<double>(0.0, 0.0))
                  ? Container()
                  : StreamBuilder(
                      initialData: null,
                      stream: this._dragStateStreamController.stream,
                      builder: (BuildContext context, AsyncSnapshot<_DragState> snapState) => (snapState.data == null ||
                              snapState.data is! _DragState ||
                              snapState.data == _DragState.notDragging)
                          ? Container()
                          : Positioned(
                              height: 140,
                              width: 140,
                              left: snapPoint.data.x - 65,
                              top: snapPoint.data.y + 10,
                              child: const Icon(
                                Icons.file_upload,
                                size: 120,
                                color: KiraColors.white,
                              ),
                            ),
                    ),
            ),
          ],
        ),
      );
}

enum _DragState {
  dragging,
  notDragging,
}
