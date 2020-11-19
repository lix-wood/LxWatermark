import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lx_watermark/lx_watermark.dart';

void main() {
  const MethodChannel channel = MethodChannel('lxwatermark');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await LxWatermark, '42');
  });
}
