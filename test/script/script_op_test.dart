import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/script/script_element.dart';
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
      ScriptOperation depth = ScriptOpDrop();
      depth.run(stack);
      expect(stack.length, 0);
    });
  });
}