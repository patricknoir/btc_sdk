import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/script/script_element.dart';
import 'package:btc_sdk/src/script/script_reader.dart';
import 'package:stack/stack.dart';
import 'package:test/test.dart';

void main() {
  group('Script', () {
    test('OP_DUP', () {
      Uint8List data = 0xFF.to8Bits();
      ScriptElement element = ScriptData(data);
      Stack<ScriptElement> stack = Stack();
      stack.push(element);
      ScriptOperation op = ScriptOpDup();
      expect(op.run(stack), 1);
      expect(stack.length, 2);
      expect(stack.pop(), stack.pop());
    });

    test('OP_DEPTH', () {
      Uint8List data = 0xFF.to8Bits();
      ScriptElement element = ScriptData(data);
      Stack<ScriptElement> stack = Stack();
      stack.push(element);
      ScriptOpDepth depth = ScriptOpDepth();
      depth.run(stack);
      final length = stack.pop() as ScriptNumber;
      expect(length.data, stack.length.to8Bits());
    });

    test('OP_DROP', () {
      Uint8List data = 0xFF.to8Bits();
      ScriptElement element = ScriptData(data);
      Stack<ScriptElement> stack = Stack();
      stack.push(element);
      ScriptOperation drop = ScriptOpDrop();
      drop.run(stack);
      expect(stack.length, 0);
    });

    test('OP_ADD', () {
      Uint8List data1 = 5.to8Bits();
      Uint8List data2 = 7.to8Bits();
      ScriptElement element1 = ScriptData(data1);
      ScriptElement element2 = ScriptData(data2);
      Stack<ScriptElement> stack = Stack();
      stack.push(element1);
      stack.push(element2);
      ScriptOperation add = ScriptOperation.OP_ADD;
      add.run(stack);
      final ScriptNumber result = stack.pop() as ScriptNumber;
      expect(result.data, ScriptNumber(12).data);
      print(result == ScriptNumber(12));
    });

    test("parse scriptPubKeyHash", () {
      // OP_DUP OP_HASH160 <public key> OP_EQUALVERIFY
      final scriptPubKeyHashHex = "76a914e993470936b573678dc3b997e56db2f9983cb0b488ac";
      ScriptReader sr = ScriptReader.fromBytes(scriptPubKeyHashHex.toUint8ListFromHex!);
      expect(sr.readNext()!.toUint8List.buffer.asByteData().getUint8(0), ScriptElement.CONST_OP_DUP);
      expect(sr.readNext()!.toUint8List.buffer.asByteData().getUint8(0), ScriptElement.CONST_OP_HASH160);
      final ScriptData sd1 = sr.readNext() as ScriptData;
      expect(sd1.data.toHex, "e993470936b573678dc3b997e56db2f9983cb0b4");
      expect(sr.readNext()!.toUint8List.buffer.asByteData().getUint8(0), ScriptElement.CONST_OP_EQUALVERIFY);
      expect(sr.hasNext, false);


    });

  });
}