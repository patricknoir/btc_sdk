import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/buffer.dart';
import 'package:btc_sdk/src/model/uint.dart';
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

    test('working with Segment', () {
      final buffer = Buffer();
      final segment = [13, 255, 96].toUint8List;
      buffer.append(segment);
      expect(buffer.isEmpty, false);
      expect(buffer.isNotEmpty, true);
      expect(buffer.length, 3);
      expect(buffer.toUint8List, segment);

      buffer + [33, 14].toUint8List;
      expect(buffer.length, 5);
      expect(buffer.toUint8List, [13, 255, 96, 33, 14]);

      expect(buffer.inspectSegment(1), [13]);
      expect(buffer.inspectSegment(2), [13, 255]);
      expect(buffer.inspectSegment(3), [13, 255, 96]);
      expect(buffer.inspectSegment(4), [13, 255, 96, 33]);
      expect(buffer.inspectSegment(5), [13, 255, 96, 33, 14]);

      expect(buffer.inspectSegment(start: 1, 5), [255, 96, 33, 14]);
      expect(buffer.inspectSegment(start: 1, 4), [255, 96, 33]);
      expect(buffer.inspectSegment(start: 2, 4), [96, 33]);

      expect(buffer.pullSegment(start: 2, 4, endian: Endian.big), [33, 96]);
      expect(buffer.toUint8List, [13, 255, 14]);
      expect(buffer.pullSegment(2), [13, 255]);
      expect(buffer.toUint8List, [14]);
    });

    test('working with Uint8', () {
      final buffer = Buffer();
      buffer.append([13, 255, 96].toUint8List);

      buffer.appendUint8(33);
      expect(buffer.length, 4);
      expect(buffer.toUint8List, [13, 255, 96, 33]);

      expect(buffer.inspectUint8(), 13);
      expect(buffer.toUint8List, [13, 255, 96, 33]);

      expect(buffer.pullUint8(), 13);
      expect(buffer.toUint8List, [255, 96, 33]);
    });

    test('working with Uint16', () {
      final buffer = Buffer();
      buffer.append([13, 255, 96].toUint8List);

      buffer.appendUint16(Uint.minUint16Value);
      expect(buffer.length, 5);
      expect(buffer.toUint8List, [13, 255, 96, 0, 1]);

      expect(buffer.inspectUint16(), 65293);
      expect(buffer.inspectUint16().to16Bits(), [13, 255]);
      expect(buffer.inspectUint16(endian: Endian.big), 3583);
      expect(buffer.inspectUint16(endian: Endian.big).to16Bits(), [255, 13]);
      expect(buffer.toUint8List, [13, 255, 96, 0, 1]);
      expect(buffer.pullUint16(), 65293);
      expect(buffer.toUint8List, [96, 0, 1]);
    });

    test('working with Uint32', () {
      final buffer = Buffer();
      buffer.append([13, 255, 96].toUint8List);

      buffer.appendUint32(Uint.minUint32Value);
      expect(buffer.length, 7);
      expect(buffer.toUint8List, [13, 255, 96, 0, 0, 1, 0]);

      expect(buffer.inspectUint32(), 6356749);
      expect(buffer.inspectUint32().to32Bits(), [13, 255, 96, 0]);
      expect(buffer.inspectUint32(endian: Endian.big), 234840064);
      expect(buffer.inspectUint32(endian: Endian.big).to32Bits(), [0, 96, 255, 13]);
      expect(buffer.toUint8List, [13, 255, 96, 0, 0, 1, 0]);
      expect(buffer.pullUint32(), 6356749);
      expect(buffer.toUint8List, [0, 1, 0]);
    });

    test('appending a Uint64', () {
      final buffer = Buffer();
      buffer.append([13, 255, 96].toUint8List);

      buffer.appendUint64(Uint.minUint64Value);
      expect(buffer.length, 11);
      expect(buffer.toUint8List, [13, 255, 96, 0, 0, 0, 0, 1, 0, 0, 0]);

      expect(buffer.inspectUint64(), 72057594044284685);
      expect(buffer.inspectUint64().to64Bits(), [13, 255, 96, 0, 0, 0, 0, 1]);
      expect(buffer.inspectUint64(endian: Endian.big), 1008630394670546945);
      expect(buffer.inspectUint64(endian: Endian.big).to64Bits(), [1, 0, 0, 0, 0, 96, 255, 13]);
      expect(buffer.toUint8List, [13, 255, 96, 0, 0, 0, 0, 1, 0, 0, 0]);
      expect(buffer.pullUint64(), 72057594044284685);
      expect(buffer.toUint8List, [0, 0, 0]);
    });

  });
}