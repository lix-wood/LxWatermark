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
  final Color color;
  final List<Shadow> shadows;
  Rich({ @required this.text, this.shadows = const [], this.fontSize = 12, this.textAlign = TextAlign.start, this.fontWeight = FontWeight.normal, this.fontStyle = FontStyle.normal, this.color = Colors.white });
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

  Future<ui.Image> loadImageByProvider(
      ImageProvider provider, {
        ImageConfiguration config = ImageConfiguration.empty,
      }) async {
    Completer<ui.Image> completer = Completer<ui.Image>(); //完成的回调
    ImageStreamListener listener;
    ImageStream stream = provider.resolve(config); //获取图片流
    listener = ImageStreamListener((ImageInfo frame, bool sync) {
      //监听
      final ui.Image image = frame.image;
      completer.complete(image); //完成
      stream.removeListener(listener); //移除监听
    });
    stream.addListener(listener); //添加监听
    return completer.future; //返回
  }

  Future<ui.Image> getDrawImage(dynamic file) async {
    try {
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
    } catch (e) {
      throw e;
    }
  }

  Future<File> init(dynamic file, { List<Rich> richText = const <Rich>[], bool local = false }) async {
    if( richText.length == 0 ) {
      richText = [
        Rich(
          text: "暂无水印文本",
          fontSize: 12,
          textAlign: TextAlign.right,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.normal,
          color: Colors.white,
          shadows: <Shadow>[
            Shadow(
                color: Color.fromRGBO(153,153,153,1),
                offset: Offset(1, 1),
                blurRadius: 20
            )
          ]
        )
      ];
    }
    ui.PictureRecorder pr = ui.PictureRecorder();
    Canvas canvas = Canvas(pr);
    ui.Image di;
    if(!local) {
      di = await loadImageByProvider(NetworkImage(file));
    } else {
      di = await getDrawImage(file);
    }

    canvas.drawImage(
        di,
        Offset( 0, 0),
        Paint()
    );


    double diWidth = double.parse('${di.width}');
    double diHeight = double.parse("${di.height}");

    for(var i in richText.asMap().keys) {
      Rich rich = richText[i];
      ui.ParagraphBuilder pb = ui.ParagraphBuilder(
          ui.ParagraphStyle(
              textAlign: rich.textAlign,
              fontWeight: rich.fontWeight,
              fontStyle: rich.fontStyle,
              fontSize: rich.fontSize
          )
      );

      pb.pushStyle(
          ui.TextStyle(
              color: rich.color,
              shadows: rich.shadows,
          )
      );
      double fontWidth = double.parse((rich.text.length * rich.fontSize).toString());
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
    Uint8List pngBytes = pngImageBytes.buffer.asUint8List();
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
    await tempFile.writeAsBytes(pngBytes);


    return tempFile;
  }
}
