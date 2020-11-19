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
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    LxWatermark lw;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      lw = await LxWatermark.getInstance();
      File file = await LxWatermark().init('assets/images/add.png');
      _platformVersion = file.path;
    } catch (e) {
      _platformVersion = "1111";
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
                child: Text('Running on: $_platformVersion\n'),
              ),
            ),
            Image.asset("$_platformVersion")
          ],
        ),
      ),
    );
  }
}
