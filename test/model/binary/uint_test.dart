import 'package:btc_sdk/src/btc_sdk_base.dart';
import 'package:btc_sdk/src/model/binary/uint.dart';
import 'package:test/test.dart';

void main() {
  group('uint', () {
    test('creation of a uint8 from int', () {
      Uint uint8 = Uint(32);
      expect(uint8.type, UintType.uint8);
      expect(uint8.toUint8List.length, 1);
      expect(uint8.toUint8List, [32]);
      expect(uint8.toUint8List.toHex, '20');
    });
    test('creation of a uint16 from int', () {
      Uint uint16 = Uint(432);
      expect(uint16.type, UintType.uint16);
      expect(uint16.toUint8List.length, 2);
      expect(uint16.toUint8List, [1, 176]);
      expect(uint16.toUint8List.toHex, '01b0');
    });
    test('creation of a uint32 from int', () {
      Uint uint32 = Uint(165536);
      expect(uint32.type, UintType.uint32);
      expect(uint32.toUint8List.length, 4);
      expect(uint32.toUint8List, [0, 2, 134, 160]);
      expect(uint32.toUint8List.toHex, '000286a0');
    });
    test('Throws assertion error when negative int is provided as input', () {
      expect(() => Uint(-4), throwsA(isA<AssertionError>()));
    });
  });
}