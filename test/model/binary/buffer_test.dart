import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
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

    test('working with VarInt with size 1', () {
      final buffer = Buffer(initial: [13, 255, 96, 33, 14].toUint8List);
      expect(buffer.inspectVarInt().toUint8List, [13]);
      expect(buffer.inspectVarInt(start: 2).toUint8List, [96]);
      expect(buffer.toUint8List, [13, 255, 96, 33, 14]);

      final varint1 = buffer.pullVarInt();
      expect(varint1.toUint8List, [13]);
      expect(buffer.toUint8List, [255, 96, 33, 14]);
      buffer.appendVarInt(varint1);
      expect(buffer.toUint8List, [255, 96, 33, 14, 13]);

      final varint2 = buffer.pullVarInt(start: 2);
      expect(varint2.toUint8List, [33]);
      expect(buffer.toUint8List, [255, 96, 14, 13]);
    });

    test('working with VarInt with size 3', () {
      final buffer = Buffer(initial: [13, 253, 96, 33, 14].toUint8List);
      expect(buffer.inspectVarInt(start: 1).toUint8List, [253, 96, 33]);
      expect(buffer.toUint8List, [13, 253, 96, 33, 14]);

      final varint3 = buffer.pullVarInt(start: 1);
      expect(varint3.toUint8List, [253, 96, 33]);
      expect(buffer.toUint8List, [13, 14]);
      buffer.appendVarInt(varint3);
      expect(buffer.toUint8List, [13, 14, 253, 96, 33]);
    });

    test('working with VarInt with size 5', () {
      final buffer = Buffer(initial: [13, 253, 96, 33, 14].toUint8List);
      VarInt varint5 = VarInt.fromValue(0x80081E5);
      expect(varint5.flag, 0xFE);
      buffer.appendVarInt(varint5);
      expect(buffer.toUint8List, [13, 253, 96, 33, 14] + varint5.toUint8List);
      buffer.appendUint8(64);
      expect(buffer.inspectVarInt(start:5), varint5);
      final extracted = buffer.pullVarInt(start:5);
      expect(extracted, varint5);
      expect(buffer.toUint8List, [13, 253, 96, 33, 14, 64]);
    });

    test('working with VarInt with size 9', () {
      final buffer = Buffer(initial: [13, 253, 96, 33, 14].toUint8List);
      VarInt varint9 = VarInt.fromValue(0x4BF583A17D59C158);
      expect(varint9.flag, 0xFF);
      buffer.appendVarInt(varint9);
      expect(buffer.toUint8List, [13, 253, 96, 33, 14] + varint9.toUint8List);
      buffer.appendUint8(64);
      expect(buffer.inspectVarInt(start:5), varint9);
      final extracted = buffer.pullVarInt(start:5);
      expect(extracted, varint9);
      expect(buffer.toUint8List, [13, 253, 96, 33, 14, 64]);
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