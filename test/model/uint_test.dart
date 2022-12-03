import 'package:btc_sdk/src/model/uint.dart';
import 'package:test/test.dart';

void main() {
  group('uint basic check', () {
    Uint uint8VarInt = Uint(128);
    Uint uint16VarInt = Uint(9999);
    Uint uint32VarInt = Uint(90000000);
    Uint uint64VarInt = Uint(8294967295);

    test('uint8 case', () {
      expect(uint8VarInt.toUint8List.length, 1);
      expect(uint8VarInt.toUint8List, [128]);
      expect(uint8VarInt.type, UintType.uint8);
      expect(128.toUint, uint8VarInt);
    });

    test('uint16 case', () {
      expect(uint16VarInt.toUint8List.length, 2);
      expect(uint16VarInt.toUint8List, [39, 15]);
      expect(uint16VarInt.type, UintType.uint16);
      expect(9999.toUint, uint16VarInt);
    });

    test('uint32 case', () {
      expect(uint32VarInt.toUint8List.length, 4);
      expect(uint32VarInt.toUint8List, [5, 93, 74, 128]);
      expect(uint32VarInt.type, UintType.uint32);
      expect(90000000.toUint, uint32VarInt);
    });

    test('uint64 case', () {
      expect(uint64VarInt.toUint8List.length, 8);
      expect(uint64VarInt.toUint8List, [0, 0, 0, 1, 238, 107, 39, 255]);
      expect(uint64VarInt.type, UintType.uint64);
      expect(8294967295.toUint, uint64VarInt);
    });

  });
}