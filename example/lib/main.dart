import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:lx_watermark/lx_watermark.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _platformVersion;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    LxWatermark lw;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
//      ''
      lw = await LxWatermark.getInstance();
//      File file = await LxWatermark().init('assets/images/add.png');
      File file = await LxWatermark().init('https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=4006671917,2375152411&fm=11&gp=0.jpg', local: false);
      _platformVersion = file;
    } catch (e) {
      throw e;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  initPlatformState();
                },
                behavior: HitTestBehavior.opaque,
                child: Text('Running on: ${_platformVersion?.path}\n'),
              ),
            ),
            _platformVersion != null? Image.file(_platformVersion):Container()
          ],
        ),
      ),
    );
  }
}
