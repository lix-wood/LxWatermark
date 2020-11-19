import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/services.dart';

class Rich {
  final String text;
  final double fontSize;
  final TextAlign textAlign;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  Rich({ @required this.text, this.fontSize, this.textAlign, this.fontWeight, this.fontStyle });
}


class LxWatermark {
  static LxWatermark instance;
  static Completer<LxWatermark> _completer;
  static Future<LxWatermark> getInstance() async {
    if (_completer == null) {
      _completer = Completer<LxWatermark>();
      try {
        _completer.complete(LxWatermark.instance);
      } on Exception catch (e) {
        _completer.completeError(e);
        final Future<LxWatermark> lxWatermarkFuture = _completer.future;
        _completer = null;
        return lxWatermarkFuture;
      }
    }
    return _completer.future;
  }

//  LxWatermark () {}

  Future<ui.Image> getDrawImage(dynamic file) async {
    dynamic result;
    if (file is String) {
      result = await rootBundle.load(file);
    } else if(file is File) {
      result = await file.readAsBytes();
    }
    await Future.delayed(Duration(milliseconds: 100));
    ui.Codec codec = await ui.instantiateImageCodec(result.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<File> init(dynamic file, { List<Rich> richText }) async {
    if( richText == null ) {
      richText = [
        Rich(
          text: "暂无水印文本",
          fontSize: 12,
          textAlign: TextAlign.right,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.normal
        )
      ];
    }
    ui.PictureRecorder pr = ui.PictureRecorder();
    Canvas canvas = Canvas(pr);
    ui.Image di = await getDrawImage(file);
    canvas.drawImage(
        di,
        Offset( 0, 0),
        Paint()
    );
    ui.ParagraphBuilder pb = ui.ParagraphBuilder(
        ui.ParagraphStyle(
            textAlign: TextAlign.right,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            fontSize: 12
        )
    );

    pb.pushStyle(
        ui.TextStyle(
          color: Colors.white,
          shadows: [
            Shadow(
                color: Color.fromRGBO(153,153,153,1),
                offset: Offset(1, 1),
                blurRadius: 20
            )
          ]
        )
    );

    double diWidth = double.parse('${di.width}');
    double diHeight = double.parse("${di.height}");

    for(var i in richText.asMap().keys) {
      Rich rich = richText[i];
      double fontWidth = double.parse((rich.text.length * 12).toString());
      if( diWidth < fontWidth) {
        fontWidth = diWidth;
      }
      print("fontWidth: $fontWidth");
      ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: fontWidth);
      pb.addText(rich.text);
      ui.Paragraph paragraph = pb.build()..layout(pc);
      canvas.drawParagraph(paragraph, Offset(diWidth - fontWidth - 10, diHeight - paragraph.height * (i + 1) - 10 ));
    }

    var picture = await pr.endRecording().toImage(di.width, di.height);//设置生成图片的宽和高
    ByteData pngImageBytes = await picture.toByteData(format: ui.ImageByteFormat.png);
    // var imgBytes = Uint8List.view(pngImageBytes.buffer); //这一行和下面这一行都是生成Uint8List格式的图片（原理还不知道）
    Uint8List pngBytes = pngImageBytes.buffer.asUint8List();
    // print("$pngBytes");

    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
    await tempFile.writeAsBytes(pngBytes);


    return tempFile;
  }
}
