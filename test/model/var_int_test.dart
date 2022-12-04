import 'package:btc_sdk/src/btc_sdk_base.dart';
import 'package:btc_sdk/src/model/var_int.dart';
import 'package:test/test.dart';

void main() {
  group('var_int', (){
    test('creation of varint size 1 by value', () {
      VarInt smallVarInt = VarInt.fromValue(187); //0xBB
      expect(smallVarInt.flag, 187);
      expect(smallVarInt.value, 0xBB);
      expect(smallVarInt.toUint8List, [187]);

      VarInt parsedVarInt = VarInt.parse([187].toUint8List);
      expect(parsedVarInt, smallVarInt);
    });

    test('creation of varint size 1-2 by value', () {
      VarInt varint1 = VarInt.fromValue(255); //0xFF
      expect(varint1.flag, 0xFD);
      expect(varint1.value, 0xFF);
      expect(varint1.toUint8List, [253, 0, 255]);
      expect(varint1.toUint8List.toHex, 'fd00ff');
      VarInt parsedVarInt1 = VarInt.parse([253, 0, 255].toUint8List);
      expect(parsedVarInt1, varint1);

      VarInt varint2 = VarInt.fromValue(13337); //0x3419
      expect(varint2.flag, 0xFD);
      expect(varint2.value, 0x3419);
      expect(varint2.toUint8List, [253, 52, 25]);
      expect(varint2.toUint8List.toHex, 'fd3419');
      VarInt parsedVarInt2 = VarInt.parse([253, 52, 25].toUint8List);
      expect(parsedVarInt2, varint2);
    });

    test('creation of varint size 3-4 by value', () {
      VarInt varint3 = VarInt.fromValue(14435729); //0xDC4591
      expect(varint3.flag, 0xFE);
      expect(varint3.value, 0xDC4591);
      expect(varint3.toUint8List, [254, 0, 220, 69, 145]);
      expect(varint3.toUint8List.toHex, 'fe00dc4591');
      VarInt parsedVarInt3 = VarInt.parse([254, 0, 220, 69, 145].toUint8List);
      expect(parsedVarInt3, varint3);

      VarInt varint4 = VarInt.fromValue(134250981); //0x80081E5
      expect(varint4.flag, 0xFE);
      expect(varint4.value, 0x80081E5);
      expect(varint4.toUint8List, [254, 8, 0, 129, 229]);
      expect(varint4.toUint8List.toHex, 'fe080081e5');
      VarInt parsedVarInt4 = VarInt.parse([254, 8, 0, 129, 229].toUint8List);
      expect(parsedVarInt4, varint4);
    });

    test('creation of varint size 5-8 by value', () {
      VarInt varint6 = VarInt.fromValue(198849843832919); //0xB4DA564E2857
      expect(varint6.flag, 0xFF);
      expect(varint6.value, 0xB4DA564E2857);
      expect(varint6.toUint8List, [255, 0, 0, 180, 218, 86, 78, 40, 87]);
      expect(varint6.toUint8List.toHex, 'ff0000b4da564e2857');
      VarInt parsedVarInt6 = VarInt.parse([255, 0, 0, 180, 218, 86, 78, 40, 87].toUint8List);
      expect(parsedVarInt6, varint6);

      VarInt varint8 = VarInt.fromValue(5473425651754713432); //0x4BF583A17D59C158
      expect(varint8.flag, 0xFF);
      expect(varint8.value, 0x4BF583A17D59C158);
      expect(varint8.toUint8List, [255, 75, 245, 131, 161, 125, 89, 193, 88]);
      expect(varint8.toUint8List.toHex, 'ff4bf583a17d59c158');
      VarInt parsedVarInt8 = VarInt.parse([255, 75, 245, 131, 161, 125, 89, 193, 88].toUint8List);
      expect(parsedVarInt8, varint8);
    });
  });
}