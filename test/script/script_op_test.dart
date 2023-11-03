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
      ScriptData element = ScriptData(data);
      Stack<ScriptData> stack = Stack();
      stack.push(element);
      ScriptOperation op = ScriptOpDup();
      expect(op.run(stack), 1);
      expect(stack.length, 2);
      expect(stack.pop(), stack.pop());
    });

    test('OP_DEPTH', () {
      Uint8List data = 0xFF.to8Bits();
      ScriptData element = ScriptData(data);
      Stack<ScriptData> stack = Stack();
      stack.push(element);
      ScriptOpDepth depth = ScriptOpDepth();
      depth.run(stack);
      final length = stack.pop() as ScriptNumber;
      expect(length.data, stack.length.to8Bits());
    });

    test('OP_DROP', () {
      Uint8List data = 0xFF.to8Bits();
      ScriptData element = ScriptData(data);
      Stack<ScriptData> stack = Stack();
      stack.push(element);
      ScriptOperation drop = ScriptOpDrop();
      drop.run(stack);
      expect(stack.length, 0);
    });

    test('OP_ADD', () {
      Uint8List data1 = 5.to8Bits();
      Uint8List data2 = 7.to8Bits();
      ScriptData element1 = ScriptData(data1);
      ScriptData element2 = ScriptData(data2);
      Stack<ScriptData> stack = Stack();
      stack.push(element1);
      stack.push(element2);
      ScriptOperation add = ScriptOperation.OP_ADD;
      add.run(stack);
      final ScriptNumber result = stack.pop() as ScriptNumber;
      expect(result.data, ScriptNumber(12).data);
      print(result == ScriptNumber(12));
    });

    test("parse scriptPubKeyHash", () {
      // OP_DUP OP_HASH160 <public key> OP_EQUALVERIFY OP_CHECKSIG
      final scriptPubKeyHashHex = "76a914e993470936b573678dc3b997e56db2f9983cb0b488ac";
      ScriptReader sr = ScriptReader.fromBytes(scriptPubKeyHashHex.toUint8ListFromHex!);
      expect(sr.readNext()!.toUint8List.buffer.asByteData().getUint8(0), ScriptElement.CONST_OP_DUP);
      expect(sr.readNext()!.toUint8List.buffer.asByteData().getUint8(0), ScriptElement.CONST_OP_HASH160);
      final ScriptData sd1 = sr.readNext() as ScriptData;
      expect(sd1.data.toHex, "e993470936b573678dc3b997e56db2f9983cb0b4");
      expect(sr.readNext()!.toUint8List.buffer.asByteData().getUint8(0), ScriptElement.CONST_OP_EQUALVERIFY);
      expect(sr.readNext()!.toUint8List.buffer.asByteData().getUint8(0), ScriptElement.CONST_OP_CHECKSIG);
      expect(sr.hasNext, false);
    });

    test("script logic", () {
      final basicTransaction = "01000000019c2e0f24a03e72002a96acedb12a632e72b6b74c05dc3ceab1fe78237f886c48010000006a47304402203da9d487be5302a6d69e02a861acff1da472885e43d7528ed9b1b537a8e2cac9022002d1bca03a1e9715a99971bafe3b1852b7a4f0168281cbd27a220380a01b3307012102c9950c622494c2e9ff5a003e33b690fe4832477d32c2d256c67eab8bf613b34effffffff02b6f50500000000001976a914bdf63990d6dc33d705b756e13dd135466c06b3b588ac845e0201000000001976a9145fb0e9755a3424efd2ba0587d20b1e98ee29814a88ac00000000".toUint8ListFromHex!;

      final transaction = Transaction.fromBytes(basicTransaction);

      ScriptExpression sigScriptExp = ScriptExpression.fromBytes(transaction.inputs[0].scriptSig!);

      Uint8List sigHash = (sigScriptExp.expression[0] as ScriptData).data;
      Uint8List pubKey = (sigScriptExp.expression[1] as ScriptData).data;

      // OP_DUP
      // OP_HASH160
      // 5fb0e9755a3424efd2ba0587d20b1e98ee29814a
      // OP_EQUALVERIFY
      // OP_CHECKSIG

      ScriptExpression pkScript = ScriptExpression([
        ScriptOperation.OP_DUP,
        ScriptOperation.OP_HASH160,
        ScriptData("5fb0e9755a3424efd2ba0587d20b1e98ee29814a".toUint8ListFromHex!),
        ScriptOperation.OP_EQUALVERIFY,
        ScriptOperation.OP_CHECKSIG
      ]);

      Stack<ScriptData> stack = Stack();

      // for (var e in sigScriptExp.expression) {
      //   e.run(stack);
      // }

      ScriptExpression fullExpression = sigScriptExp >> pkScript;

      int result = fullExpression.run(stack);

      print(result);
    });

  });
}