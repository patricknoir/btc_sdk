import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/buffer.dart';
import 'package:test/test.dart';

void main() {
  group('Buffer', () {

    test('buffer creation', (){
      final buffer = Buffer();
      expect(buffer.isEmpty, true);
      expect(buffer.isNotEmpty, false);
      expect(buffer.length, 0);
      expect(buffer.toUint8List, Uint8List(0));

      final nonEmptyBuffer = Buffer(initial: [13, 255, 96].toUint8List);
      expect(nonEmptyBuffer.isEmpty, false);
      expect(nonEmptyBuffer.isNotEmpty, true);
      expect(nonEmptyBuffer.length, 3);
      expect(nonEmptyBuffer.toUint8List, [13, 255, 96]);
    });

    test('appending a Uint8List', () {
      final buffer = Buffer();
      buffer.append([13, 255, 96].toUint8List);
      expect(buffer.isEmpty, false);
      expect(buffer.isNotEmpty, true);
      expect(buffer.length, 3);
      expect(buffer.toUint8List, [13, 255, 96]);

      buffer + [33, 14].toUint8List;
      expect(buffer.length, 5);
      expect(buffer.toUint8List, [13, 255, 96, 33, 14]);

    });

  });
}